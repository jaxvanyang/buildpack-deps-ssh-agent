# Disclaimer: this file is modified from jenkinsci/docker-ssh-agent
# Permalink: https://github.com/jenkinsci/docker-ssh-agent/blob/0313f2b2eb7663186b712f3284e010596fb644a8/17/bullseye/Dockerfile

FROM arm64v8/eclipse-temurin:17.0.5_8-jdk-focal as jre-build

# Generate smaller java runtime without unneeded files
# for now we include the full module path to maintain compatibility
# while still saving space
RUN jlink \
				--add-modules ALL-MODULE-PATH \
				--no-man-pages \
				--compress=2 \
				--output /javaruntime

FROM arm64v8/buildpack-deps:sid

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME=${JENKINS_AGENT_HOME}
ARG AGENT_WORKDIR="${JENKINS_AGENT_HOME}/agent"
# Persist agent workdir path through an environment variable for people extending the image
ENV AGENT_WORKDIR=${AGENT_WORKDIR}

RUN groupadd -g ${gid} ${group} \
		&& useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}" \
		# Prepare subdirectories
		&& mkdir -p "${JENKINS_AGENT_HOME}/.ssh/" "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}/.jenkins" \
		# Make sure that user 'jenkins' own these directories and their content
		&& chown -R "${uid}":"${gid}" "${JENKINS_AGENT_HOME}" "${AGENT_WORKDIR}"

# Use mirror to speed up apt
RUN <<EOF cat > /etc/apt/sources.list
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ sid main
EOF
RUN rm -f /etc/apt/sources.list.d/debian.sources

RUN apt-get update \
		&& apt-get install --no-install-recommends -y \
			git-lfs \
			less \
			netcat-traditional \
			openssh-server \
			patch \
			dejagnu \
			libgmp-dev \
			libmpfr-dev \
			libmpc-dev \
			flex \
			bison \
			bc \
			libelf-dev \
			zip \
			libx11-dev \
			libxext-dev \
			libxrender-dev \
			libxrandr-dev \
			libxtst-dev \
			libxt-dev \
			libcups2-dev \
			libasound2-dev \
			ant \
		&& rm -rf /var/lib/apt/lists/*

# setup SSH server
RUN sed -i /etc/ssh/sshd_config \
				-e 's/#PermitRootLogin.*/PermitRootLogin no/' \
				-e 's/#RSAAuthentication.*/RSAAuthentication yes/' \
				-e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
				-e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
				-e 's/#LogLevel.*/LogLevel INFO/' && \
		mkdir /var/run/sshd

# VOLUME directive must happen after setting up permissions and content
VOLUME "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}"/.jenkins "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

RUN echo "PATH=${PATH}" >> /etc/environment
COPY setup-sshd /usr/local/bin/setup-sshd

EXPOSE 22

ENTRYPOINT ["setup-sshd"]

# LABEL \
#		org.opencontainers.image.vendor="Jenkins project" \
#		org.opencontainers.image.title="Official Jenkins SSH Agent Docker image" \
#		org.opencontainers.image.description="A Jenkins agent image which allows using SSH to establish the connection" \
#		org.opencontainers.image.url="https://www.jenkins.io/" \
#		org.opencontainers.image.source="https://github.com/jenkinsci/docker-ssh-agent" \
#		org.opencontainers.image.licenses="MIT"
