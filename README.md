# buildpack-deps-ssh-agent

Docker images & VMs for Jenkins agents connected over SSH, based on buildpack-deps.

## About this project

- What is this for?
  See [jaxvanyang/jenkins-bench: Self-use benchmarks for Jenkins.](https://github.com/jaxvanyang/jenkins-bench)

- About buildpack-deps:
  See [buildpack-deps - Official Image | Docker Hub](https://hub.docker.com/_/buildpack-deps).

- About ssh-agent:
  See [jenkins/ssh-agent - Docker Image | Docker Hub](https://hub.docker.com/r/jenkins/ssh-agent).

- Folder structure:
  - For Docker container: `<arch>/<code_name>/Dockerfile`.
  - For VM: `vm/<arch>/<code_name>/`.
  - Example:
    ```bash
    .
    ├── amd64
    │   └── sid
    │       └── Dockerfile
    ├── arm64v8
    │   └── sid
    │       └── Dockerfile
    ├── riscv64
    │   └── sid
    │       └── Dockerfile
    └── vm
        └── amd64
            └── sid
                ├── install.sh
                └── preseed.cfg
    ```

- Usage: For details, see [Makefile](Makefile)
  - Build & run Docker containers:
    ```bash
    JENKINS_AGENT_SSH_PUBKEY="XX" make clean build agents
    ```
  - Build & run VMs:
    ```bash
    JENKINS_AGENT_SSH_PUBKEY="XX" make clean-vms install-vms
    ```

## References

- [Docker Docs: How to build, share, and run applications | Docker Documentation](https://docs.docker.com/)
- [libvirt: The virtualization API](https://libvirt.org/)
- [Virtual Machine Manager](https://virt-manager.org/index.html)
- [libvirt - ArchWiki](https://wiki.archlinux.org/title/Libvirt)
- [pin/debian-vm-install: Debian unattended VM installation with virt-install and pressed.cfg](https://github.com/pin/debian-vm-install)
- [DebianInstaller/Preseed - Debian Wiki](https://wiki.debian.org/DebianInstaller/Preseed)
- [debian.org/releases/testing/example-preseed.txt](https://www.debian.org/releases/testing/example-preseed.txt)
- [Index of /debian/dists/sid/ | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/debian/dists/sid/)
- [DebianUnstable - Debian Wiki](https://wiki.debian.org/DebianUnstable#Installation)
- [Giovanni Mascellani / dqib · GitLab](https://gitlab.com/giomasce/dqib)
- [CoelacanthusHex/archriscv-scriptlet: Useful scripts for Arch RISC-V project](https://github.com/CoelacanthusHex/archriscv-scriptlet)
