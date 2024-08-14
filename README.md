# cape-docker
Quickly deploy CAPEv2 Sandbox service in Docker

## Overview
This project facilitates the Docker-based deployment of CAPEv2, a malware analysis system. It orchestrates the necessary components allowing the CAPEv2 container to communicate with VirtualBox on the host machine using custom vbox-server and vbox-client setups. The project automates the building of a Docker image for CAPEv2, along with compiling the vbox-server and vbox-client binaries that relay VBoxManage commands from within the Docker container to the host's VirtualBox.

Additionally, this setup configures iptables to forward traffic so that the CAPEv2 container can interact with virtual machines on the `vboxnet0` network (192.168.56.0) and allows these VMs to access the CAPEv2 container's result_server on port 2042.

## Prerequisites
- Docker
- Go Compiler
- VirtualBox
- iptables (for setting up network forwarding)

## Building the Project
To build the vbox-server, vbox-client, and the CAPEv2 Docker image, run the following command from the project directory:

```bash
make all
```

This command will:
- Compile the vbox-server and vbox-client binaries.
- Build the Docker image for CAPEv2 tagged as `cape:latest`.

## Cleanup
To clean up the binaries and temporary files generated during the build process, you can run:

```bash
make clean
```

## Preparing to Run
Before starting the Docker container, ensure the vbox-server is running:

```bash
./bin/vbox-server
```

This server will create a `vbox.sock` file, which is needed by the container.

## Running the Project
After ensuring the vbox-server is running and `vbox.sock` has been created, deploy the CAPEv2 container with the following Docker command:
