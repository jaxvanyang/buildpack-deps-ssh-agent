NAME := buildpack-deps-ssh-agent
TAGS := sid
IMAGES := amd64-sid
AGENTS := amd64-sid-agent
COMMON_DEPS := setup-sshd

## Macros
docker_build = cp ${COMMON_DEPS} "$(1)/$(2)" && cd "$(1)/$(2)" && \
							 docker build -t "${NAME}:$(2)" . && \
							 rm ${COMMON_DEPS}
docker_run = docker run -d \
						 -v "$(1)-workdir:/home/jenkins/agent:rw" \
						 -v "/home/jax/Public/resources:/resources:ro" \
						 -p "$(2):22" \
						 --name "$(1)" \
						 --restart on-failure:5 \
						 "$(3)" \
						 "$${JENKINS_AGENT_SSH_PUBKEY}"

.PHONY: build stop clean
.PHONY: ${IMAGES} ${AGENTS}

build: ${IMAGES}

amd64-sid: amd64/sid/Dockerfile ${COMMON_DEPS}
	$(call docker_build,amd64,sid)

amd64-sid-agent:
	$(call docker_run,$@,2200,${NAME}:sid)

stop:
	-docker stop ${AGENTS}

clean-agents: stop
	-docker rm ${AGENTS}

clean: clean-agents
	-@for tag in ${TAGS}; do docker rmi "${NAME}:$${tag}"; done
