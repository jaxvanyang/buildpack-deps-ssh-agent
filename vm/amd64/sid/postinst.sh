#!/bin/bash
# This script is run by debian installer using preseed/late_command
# directive, see preseed.cfg

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
)

# Create a user for Jenkins
user=jenkins
group=jenkins
uid=1000
gid=1000
JENKINS_AGENT_HOME="/home/${user}"
AGENT_WORKDIR="${JENKINS_AGENT_HOME}/agent"

groupadd -g ${gid} ${group}
useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"
# Prepare subdirectories
mkdir -p "${JENKINS_AGENT_HOME}/.ssh/" "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}/.jenkins"
# Make sure that user 'jenkins' own these directories and their content
chown -R "${uid}":"${gid}" "${JENKINS_AGENT_HOME}" "${AGENT_WORKDIR}"

# Setup SSH server
sed -i /etc/ssh/sshd_config \
	-e 's/#PermitRootLogin.*/PermitRootLogin no/' \
	-e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
	-e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
	-e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
	-e 's/#LogLevel.*/LogLevel INFO/'

# Install SSH key for Jenkins user
mv /tmp/authorized_keys "${JENKINS_AGENT_HOME}/.ssh/"
chmod 0700 -R "${JENKINS_AGENT_HOME}/.ssh"
chown -R "${uid}":"${gid}" "${JENKINS_AGENT_HOME}/.ssh" 

# Remove timeout on boot.
sed -i 's/TIMEOUT=5/TIMEOUT=0/g' /etc/default/grub
update-grub

# Remove some non-essential packages.
# DEBIAN_FRONTEND=noninteractive apt-get purge -y nano laptop-detect tasksel dictionaries-common emacsen-common iamerican ibritish ienglish-common ispell

# Install buildpack-deps packages
apt-get install -y --no-install-recommends \
	"${sid_curl_packages[@]}" \
	"${sid_scm_packages[@]}" \
	"${sid_packages[@]}" \
	"${packages[@]}"
rm -rf /var/lib/apt/lists/*
