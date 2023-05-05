HUB_PREFIX := jaxvanyang
NAME := buildpack-deps-ssh-agent
TAGS := sid-amd64 sid-riscv64 sid-arm64v8
IMAGES := amd64-sid riscv64-sid arm64v8-sid
AGENTS := amd64-sid-agent riscv64-sid-agent arm64v8-sid-agent
VMS := amd64-sid-vm arm64v8-sid-vm riscv64-sid-vm
COMMON_DEPS := setup-sshd
VM_DEPS := install.sh preseed.cfg postinst.sh

## Macros
docker_build = cp ${COMMON_DEPS} "$(1)/$(2)" && cd "$(1)/$(2)" && \
							 docker build -t "${HUB_PREFIX}/${NAME}:$(2)-$(1)" . && \
							 rm ${COMMON_DEPS}
docker_run = docker run -d \
						 -v "$(1)-workdir:/home/jenkins/agent:rw" \
						 -v "/mnt/resources:/mnt/resources:ro" \
						 -p "$(2):22" \
						 --name "$(1)" \
						 --restart unless-stopped \
						 "${HUB_PREFIX}/${NAME}:$(3)" \
						 "$${JENKINS_AGENT_SSH_PUBKEY}"
vm_install = cd "vm/$(1)/$(2)" && \
						 ./install.sh "$(1)-$(2)-vm" "$${JENKINS_AGENT_SSH_PUBKEY}"
vm_clean = virsh destroy "${1}"; \
					 virsh undefine "${1}" --remove-all-storage --nvram

.PHONY: build push pull test stop clean-agents agents clean
.PHONY: clean-vms vm-install start-vms
.PHONY: ${IMAGES} ${AGENTS} ${VMS}

agents: ${AGENTS}

build: ${IMAGES}

install-vms: ${VMS}

start-vms:
	for vm in ${VMS}; do virsh start $${vm}; done

amd64-sid: amd64/sid/Dockerfile ${COMMON_DEPS}
	$(call docker_build,amd64,sid)

amd64-sid-agent:
	$(call docker_run,$@,2200,sid-amd64)

riscv64-sid: riscv64/sid/Dockerfile ${COMMON_DEPS}
	$(call docker_build,riscv64,sid)

riscv64-sid-agent:
	$(call docker_run,$@,2201,sid-riscv64)

arm64v8-sid: arm64v8/sid/Dockerfile ${COMMON_DEPS}
	$(call docker_build,arm64v8,sid)

arm64v8-sid-agent:
	$(call docker_run,$@,2202,sid-arm64v8)

amd64-sid-vm: $(patsubst %,vm/amd64/sid/%,${VM_DEPS})
	$(call vm_install,amd64,sid)

arm64v8-sid-vm: $(patsubst %,vm/arm64v8/sid/%,${VM_DEPS})
	$(call vm_install,arm64v8,sid)

riscv64-sid-vm:
	make -C vm/riscv64/sid install

push:
	for tag in ${TAGS}; do docker push "${HUB_PREFIX}/${NAME}:$${tag}"; done

pull:
	for tag in ${TAGS}; do docker pull "${HUB_PREFIX}/${NAME}:$${tag}"; done

test: clean-agents ${AGENTS}

stop:
	-docker stop ${AGENTS}

clean-agents: stop
	-docker rm ${AGENTS}

clean-vms:
	-@for vm in ${VMS}; do $(call vm_clean,$${vm}); done
	-make -C vm/riscv64/sid clean-vm

clean: clean-agents
	-@for tag in ${TAGS}; do docker rmi "${HUB_PREFIX}/${NAME}:$${tag}"; done
	-make -C vm/riscv64/sid clean
