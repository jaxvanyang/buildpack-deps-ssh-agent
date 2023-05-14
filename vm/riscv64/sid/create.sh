#!/bin/bash

# dqib - Debian quick image baker
# Copyright © 2019 Giovanni Mascellani <gio@debian.org>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

set -e

SYSTEM="riscv64-virt"
# Create a user for Jenkins agent
user=jenkins
group=jenkins
uid=1000
gid=1000
JENKINS_AGENT_HOME="/home/${user}"
AGENT_WORKDIR="${JENKINS_AGENT_HOME}/agent"

if [ -z "${HOSTNAME}" ]; then
	HOSTNAME="riscv64-sid-vm"
fi

if [ -z "$JENKINS_AGENT_SSH_PUBKEY" ]; then
	echo "Error: env JENKINS_AGENT_SSH_PUBKEY must be set!" >&2
	exit 1
fi

if [ -z "$IP" ]; then
	IP="192.168.122.30"
fi

if [ -z "$MEM" ]; then
	MEM="1G"
fi

if [ -z "$IMAGE_SIZE" ]; then
	IMAGE_SIZE="32G"
fi

if [ -z "$SUITE" ]; then
	SUITE="sid"
fi

if [ -z "$MIRROR" ]; then
	MIRROR="_default"
fi

if [ -z "$MIRROR2" ]; then
	MIRROR2="_default"
fi

if [ -z "${DIR}" ]; then
	# DIR="$(mktemp -d /tmp/$SYSTEM-XXXXXXX)"
	DIR="$SYSTEM"
	mkdir -p "${DIR}"
fi
QEMU_IMG="${DIR}/${HOSTNAME}.qcow2"

FOUND="no"
PORTS="no"

# packages used by buildpack-deps
sid_curl_packages=(
	ca-certificates
	curl
	netbase
	wget
	gnupg
	dirmngr
)
sid_scm_packages=(
	git
	mercurial
	openssh-client
	subversion
	procps
)
# libmysqlclient-dev is not included
sid_packages=(
	autoconf
	automake
	bzip2
	dpkg-dev
	file
	g++
	gcc
	imagemagick
	libbz2-dev
	libc6-dev
	libcurl4-openssl-dev
	libdb-dev
	libevent-dev
	libffi-dev
	libgdbm-dev
	libglib2.0-dev
	libgmp-dev
	libjpeg-dev
	libkrb5-dev
	liblzma-dev
	libmagickcore-dev
	libmagickwand-dev
	libmaxminddb-dev
	libncurses5-dev
	libncursesw5-dev
	libpng-dev
	libpq-dev
	libreadline-dev
	libsqlite3-dev
	libssl-dev
	libtool
	libwebp-dev
	libxml2-dev
	libxslt-dev
	libyaml-dev
	make
	patch
	unzip
	xz-utils
	zlib1g-dev
)
# other needed packages
packages=(
	openjdk-17-jdk-headless
	dejagnu
	libgmp-dev
	libmpfr-dev
	libmpc-dev
	flex
	bison
	bc
	libelf-dev
	zip
	libx11-dev
	libxext-dev
	libxrender-dev
	libxrandr-dev
	libxtst-dev
	libxt-dev
	libcups2-dev
	libasound2-dev
	ant
)

if [ "$SYSTEM" == "riscv64-virt" ]; then
	ARCH="riscv64"
	LINUX="linux-image-riscv64"
	QEMU_ARCH="riscv64"
	QEMU_MACHINE="virt"
	QEMU_CPU="rv64"
	QEMU_DISK="-device virtio-blk-device,drive=hd -drive file=image.qcow2,if=none,id=hd"
	QEMU_NET_DEVICE="-device virtio-net-device,netdev=net"
	LINUX_FILENAME="vmlinuz"
	INITRD_FILENAME="initrd.img"
	CONSOLE="ttyS0"
	PORTS="yes"
	FOUND="yes"
fi

if [ "$FOUND" != "yes" ]; then
	echo "Could not find system type: $SYSTEM"
	exit 1
fi

if [ "$MIRROR" == "_default" ]; then
	if [ "$PORTS" == "no" ]; then
	    MIRROR="deb [arch=$ARCH] http://mirrors.aliyun.com/debian $SUITE main"
	    KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"
	else
	    MIRROR="deb [arch=$ARCH] http://mirrors.aliyun.com/debian-ports $SUITE main"
	    KEYRING="/usr/share/keyrings/debian-ports-archive-keyring.gpg"
	fi
fi

if [ "$MIRROR2" == "_default" ]; then
	if [ "$PORTS" == "no" ]; then
	    MIRROR2="_no"
	else
	    MIRROR2="deb [arch=$ARCH] http://mirrors.aliyun.com/debian-ports unreleased main"
	fi
fi

set -v

# Create the image
mkdir -p "${DIR}"
qemu-img create -f qcow2 "${QEMU_IMG}" "${IMAGE_SIZE}"
modprobe nbd max_part=16
qemu-nbd -c /dev/nbd0 "${QEMU_IMG}"

sfdisk /dev/nbd0 <<EOF
label: gpt
label-id: F7E350FA-4625-5146-9299-B477AD78D0E2
device: /dev/nbd0
unit: sectors
sector-size: 512

/dev/nbd0p1 : start=        2048, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, bootable
EOF

mkfs.ext4 /dev/nbd0p1
e2label /dev/nbd0p1 rootfs
mount --mkdir /dev/nbd0p1 "${DIR}/chroot"

# Create the filesystem
if [ "$MIRROR2" == "_no" ]; then
	mmdebstrap \
		--architectures="$ARCH" \
		--variant=required \
		--include="$LINUX",debian-ports-archive-keyring,zstd \
		--verbose \
		"$SUITE" "${DIR}/chroot" "$MIRROR"
else
	mmdebstrap \
		--architectures="$ARCH" \
		--variant=required \
		--include="$LINUX",debian-ports-archive-keyring,zstd \
		--verbose \
		"$SUITE" "${DIR}/chroot" "$MIRROR" "$MIRROR2"
fi

# Install a simple fstab and set hostname
cat > "${DIR}/chroot/etc/fstab" <<EOF
LABEL=rootfs	/	ext4	user_xattr,errors=remount-ro	0	1
EOF
echo "${HOSTNAME}" > "${DIR}/chroot"/etc/hostname

# Create and set passwords for root and user jenkins
# chroot "${DIR}/chroot" adduser --gecos "Debian user,,," --disabled-password debian
echo "root:nopasswd" | chroot "${DIR}/chroot" chpasswd
chroot "${DIR}/chroot" groupadd -g ${gid} ${group}
chroot "${DIR}/chroot" useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"
# Prepare subdirectories
chroot "${DIR}/chroot" mkdir -p "${JENKINS_AGENT_HOME}/.ssh/" "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}/.jenkins"
# Make sure that user 'jenkins' own these directories and their content
chroot "${DIR}/chroot" chown -R "${uid}":"${gid}" "${JENKINS_AGENT_HOME}" "${AGENT_WORKDIR}"

# Update APT database, install important packages (except vim-* and
# isc-dhcp-*, which often fail to install) and openssh-server
chroot "${DIR}/chroot" apt-get update
chroot "${DIR}/chroot" bash -c 'cat /var/lib/apt/lists/*_Packages  | grep '\''^\(Package\|Priority\): '\'' | grep -B 1 '\''^Priority: important'\'' | grep ^Package | cut -d'\'' '\'' -f2 | grep -v ^vim | grep -v ^isc-dhcp | xargs apt-get install -y --no-install-recommends'
chroot "${DIR}/chroot" apt-get install -y --no-install-recommends openssh-server

# Install buildpack-deps packages & OpenJDK
# Use systemd-nspawn to avoid /proc problem
systemd-nspawn -D "${DIR}/chroot" apt-get install -y --no-install-recommends \
	"${sid_curl_packages[@]}" \
	"${sid_scm_packages[@]}" \
	"${sid_packages[@]}" \
	"${packages[@]}"
# Clean APT cache
rm -rf /var/lib/apt/lists/*

# Disable predictable interface naming and configure default libvirt network
ln -s /dev/null "${DIR}/chroot"/etc/systemd/network/99-default.link
cat > "${DIR}/chroot/etc/network/interfaces" <<EOF
auto eth0
#iface eth0 inet dhcp
iface eth0 inet static
      address ${IP}/24
      gateway 192.168.122.1
EOF
cat > "${DIR}/chroot/etc/resolv.conf" <<EOF
nameserver 192.168.122.1
EOF

# Setup SSH server
sed -i "${DIR}/chroot/etc/ssh/sshd_config" \
	-e 's/#PermitRootLogin.*/PermitRootLogin no/' \
	-e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
	-e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
	-e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
	-e 's/#LogLevel.*/LogLevel INFO/'

# Install SSH key for Jenkins user
mkdir -p "${DIR}/chroot/${JENKINS_AGENT_HOME}/.ssh"
echo "${JENKINS_AGENT_SSH_PUBKEY}" > "${DIR}/chroot/${JENKINS_AGENT_HOME}/.ssh/authorized_keys"
chmod 0700 -R "${DIR}/chroot/${JENKINS_AGENT_HOME}/.ssh"
chown -R "${uid}":"${gid}" "${DIR}/chroot/${JENKINS_AGENT_HOME}/.ssh" 

# Recreate initrd
chroot "${DIR}/chroot" update-initramfs -k all -c

# RISC-V64 specific things
if [ "$SYSTEM" == "riscv64-virt" ]; then
	chroot "${DIR}/chroot" apt-get install -y u-boot-menu
	chroot "${DIR}/chroot" ln -sf /dev/null /etc/systemd/system/serial-getty@hvc0.service
	cat >> "${DIR}/chroot"/etc/default/u-boot <<EOF
U_BOOT_PARAMETERS="rw noquiet root=LABEL=rootfs"
U_BOOT_FDT_DIR="noexist"
EOF
	chroot "${DIR}/chroot" u-boot-update
fi

umount "${DIR}/chroot"
qemu-nbd -d /dev/nbd0
