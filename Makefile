NAME := buildpack-deps-ssh-agent
TAGS := sid
AGENTS := amd64-sid-agent
COMMON_DEPS := setup-sshd

## Macros
docker_build = cp ${COMMON_DEPS} "$(1)/$(2)" && cd "$(1)/$(2)" && \
							 docker build -t "${NAME}:$(2)" . && \
							 rm ${COMMON_DEPS}

.PHONY: build amd64-sid stop clean

build: amd64-sid

amd64-sid: amd64/sid/Dockerfile ${COMMON_DEPS}
	$(call docker_build,amd64,sid)

stop:
	-docker stop ${AGENTS}

clean: stop
	-docker rm ${AGENTS}
	-@for tag in ${TAGS}; do docker rmi "${NAME}:$${tag}"; done
