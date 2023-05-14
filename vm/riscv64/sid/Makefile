DIR ?= riscv64-virt
HOSTNAME ?= riscv64-sid-vm
IP ?= 192.168.122.30
IMG_NAME := ${HOSTNAME}.qcow2
QEMU_IMG := ${DIR}/${IMG_NAME}
POOL_DIR ?= /mnt/images
POOL_IMG := ${POOL_DIR}/${IMG_NAME}

.PHONY: clean-vm clean build install

install: ${POOL_IMG} install.sh
	./install.sh "${HOSTNAME}"

${POOL_IMG}: ${QEMU_IMG}
	cp $^ $@

build: ${QEMU_IMG}

${QEMU_IMG}: create.sh
	sudo DIR="${DIR}" \
		HOSTNAME="${HOSTNAME}" \
		IP="${IP}" \
		JENKINS_AGENT_SSH_PUBKEY="$${JENKINS_AGENT_SSH_PUBKEY}" \
		POOL_DIR="${POOL_DIR}" \
		PATH="/usr/sbin:${PATH}" \
		./create.sh

clean:
	-sudo rm -rf "${DIR}"

clean-vm:
	-virsh destroy "${HOSTNAME}"
	-virsh undefine "${HOSTNAME}" --remove-all-storage
