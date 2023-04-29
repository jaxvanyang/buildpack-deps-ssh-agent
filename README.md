# buildpack-deps-ssh-agent

Docker images & VMs for Jenkins agents connected over SSH, based on buildpack-deps.

## About this project

- About buildpack-deps:
  See [buildpack-deps - Official Image | Docker Hub](https://hub.docker.com/_/buildpack-deps).

- About ssh-agent:
  See [jenkins/ssh-agent - Docker Image | Docker Hub](https://hub.docker.com/r/jenkins/ssh-agent)

- Folder structure:
  - For Docker container: `arch/code_name/Dockerfile`
  - Example:
    ```bash
    .
    ├── amd64
    │   └── sid
    │       └── Dockerfile
    ├── arm64v8
    │   └── sid
    │       └── Dockerfile
    └── riscv64
        └── sid
            └── Dockerfile
    ```

- Usage: See [Makefile](Makefile)

## References

- [Docker Docs: How to build, share, and run applications | Docker Documentation](https://docs.docker.com/)
- [libvirt: The virtualization API](https://libvirt.org/)
- [Virtual Machine Manager](https://virt-manager.org/index.html)
- [libvirt - ArchWiki](https://wiki.archlinux.org/title/Libvirt)
- [pin/debian-vm-install: Debian unattended VM installation with virt-install and pressed.cfg](https://github.com/pin/debian-vm-install)
