#!/bin/bash
#
# Thanks Dmitri Popov for the base script: https://github.com/pin/debian-vm-install

set -e

if [ -z "${IMAGE}" ]; then
	IMAGE="/mnt/images/${1}.qcow2"
fi

LINUX_VARIANT="debiantesting"
LOADER="/usr/share/qemu/opensbi-riscv64-generic-fw_dynamic.bin"
KERNEL="/usr/share/u-boot-qemu-bin/qemu-riscv64_smode/uboot.elf"
KERNEL_ARGS="root=LABEL=rootfs console=ttyS0"

help_msg() {
	cat <<EOF
Usage: $0 <GUEST_NAME>

	GUEST_NAME	used as guest hostname, name of the VM and image file name.

Examples:

	# create a guest named "riscv64-sid-vm"
	$0 riscv64-sid-vm
EOF
}

install_debian_sid() {
	cat <<EOF
Run "virsh console ${1}" to monitor the installation process.
EOF

	virt-install \
		--arch riscv64 \
		--name="${1}" \
		--memory 1024 \
		--vcpus 2 \
		--import \
		--disk path="${IMAGE}",size=16,bus=virtio,cache=none \
		--osinfo detect=on,name="${LINUX_VARIANT}" \
		--virt-type=qemu \
		--graphics none \
		--autoconsole none \
		--network default \
		--boot "loader=${LOADER},kernel=${KERNEL},kernel_args=\"${KERNEL_ARGS}\""
}

main() {
	if [ $# -ne 1 ]; then
		help_msg >&2
		exit 1
	fi

	install_debian_sid "${1}"
}

main "$@"
