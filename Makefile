NAME := buildpack-deps-ssh-agent
TAGS := sid
COMMON_DEPS := setup-sshd

## Macros
docker_build = cp ${COMMON_DEPS} "$(1)/$(2)" && cd "$(1)/$(2)" && \
							 docker build -t "${NAME}:$(2)" . && \
							 rm ${COMMON_DEPS}

.PHONY: build amd64-sid clean

build: amd64-sid

amd64-sid: amd64/sid/Dockerfile ${COMMON_DEPS}
	$(call docker_build,amd64,sid)

clean:
	-@for tag in ${TAGS}; do docker rmi "${NAME}:$${tag}"; done
