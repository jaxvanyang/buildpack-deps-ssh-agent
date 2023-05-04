#!/bin/bash
# A script to create debian sid VM as a KVM guest using virt-install in fully
# automated way based on preseed.cfg.
#
# Thanks Dmitri Popov for the base script: https://github.com/pin/debian-vm-install

set -e

# Domain is necessary in order to avoid debian installer to
# require manual domain entry during the install.
DOMAIN="${1}.local"
DIST_URL="https://mirrors.tuna.tsinghua.edu.cn/debian/dists/sid/main/installer-arm64"
LINUX_VARIANT="debiantesting"

help_msg() {
	cat <<EOF
Usage: $0 <GUEST_NAME> <JENKINS_AGENT_SSH_PUBKEY>

	GUEST_NAME	used as guest hostname, name of the VM and image file name.

	JENKINS_AGENT_SSH_PUBKEY	SSH public key to connect VM as user jenkins.

Examples:

	# create a guest named "arm64v8-sid-vm"
	$0 arm64v8-sid-vm
EOF
}

install_debian_sid() {
	cat <<EOF
Run "virsh console ${1}" to monitor the installation process.
EOF

	virt-install \
		--arch aarch64 \
		--name="${1}" \
		--memory 1024 \
		--vcpus 2 \
		--disk path="/mnt/images/${1}.qcow2",size=16,bus=virtio,cache=none \
		--initrd-inject=preseed.cfg \
		--initrd-inject=postinst.sh \
		--initrd-inject=authorized_keys \
		--location ${DIST_URL} \
		--osinfo detect=on,name="${LINUX_VARIANT}" \
		--virt-type=qemu \
		--graphics none \
		--autoconsole none \
		--wait \
		--network default \
		--extra-args="auto=true hostname="${1}" domain="${DOMAIN}" console=tty0 console=ttyS0,115200n8 serial"
}

main() {
	if [ $# -ne 2 ] || [ -z "${2}" ]; then
		help_msg >&2
		exit 1
	fi

	# Store SSH public key to file for copying to VM
	echo "${2}" > authorized_keys

	install_debian_sid "${1}"
	rm authorized_keys
}

main "$@"
