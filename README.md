# Derro

Derro is a project for running Vagrant inside a Docker container, providing a convenient and reproducible environment for Vagrant-based workflows. This setup is based on AlmaLinux 9 and includes all necessary tools for SSH, systemd, and Vagrant user provisioning.

## Features
- AlmaLinux 9 base image
- Systemd enabled for service management
- SSH server pre-configured and exposed on port 22
- Pre-created `vagrant` user with passwordless sudo
- Automatic setup of SSH keys for the `vagrant` user (using your GitHub public keys)
- Useful utilities pre-installed (git, wget, vim, python3, etc.)

## Usage

### Build the Docker Image
```sh
docker build -t derro .
```

### Run the Container
```sh
docker run --privileged -d \
  --name derro \
  -p 2222:22 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  derro
```

- The `--privileged` flag and cgroup mount are required for systemd to function properly inside the container.
- SSH will be available on port 2222 of your host.

### Connect via SSH
```sh
ssh vagrant@localhost -p 2222
# Password: vagrant
```

### Customizing SSH Keys
By default, the container fetches your public keys from GitHub (`https://github.com/iladin.keys`).
To use a different key, modify the relevant line in the Dockerfile.

## Notes
- This image is intended for development and testing purposes.
- For full Vagrant functionality, you may need to install Vagrant and VirtualBox or another provider inside the container, or mount them from the host.

## Credits
- Inspired by [star3am/hashiqube](https://github.com/star3am/hashiqube)

## License
MIT
