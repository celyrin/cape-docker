# cape-docker
Deploy [CAPEv2 Sandbox](https://github.com/kevoreilly/CAPEv2.git) within a Docker container for efficient malware analysis.

## Overview
This repository contains all the necessary configurations to deploy the CAPEv2 malware analysis system using Docker. The setup includes orchestrating the communication between the CAPEv2 container and VirtualBox installed on the host machine through custom vbox-server and vbox-client components. It also enables network capture using tcpdump within the container which communicates with the guest VMs on the host’s network.

## Prerequisites
- Docker
- Go Compiler
- VirtualBox

## Building the Project
Run the following command in the project directory to build the vbox-server, vbox-client, and the CAPEv2 Docker image:

```bash
make all
```

This command compiles the necessary binaries and builds the CAPEv2 Docker image tagged as `cape:latest`.
If you don't want to build the project yourself, you can download the latest release package from the [Releases](https://github.com/celyrin/cape-docker/releases) section.

## Cleanup
Remove binaries and temporary files with:

```bash
make clean
```

## Preparing to Run
Start the vbox-server before deploying the Docker container:

```bash
./bin/vbox-server
```

The server generates a `vbox.sock` file required by the Docker container.

## Configuring CAPE
Navigate to the configuration directory and set up the configuration files:
```bash
cd ./CAPEv2/conf
./copy_configs.sh
```

Modify `cuckoo.conf` to use VirtualBox:
```bash
cuckoo.machinery=virtualbox
```

Specify the result server IP in `cuckoo.conf`. Use the IP address of vboxnet0 or other VirtualBox network cards in the host machine:
```bash
resultserver.ip=<ip_of_host>
```

Follow the [official documentation](https://capev2.readthedocs.io/en/latest/installation/guest/index.html) to configure guest VMs in `virtualbox.conf`.

## Running the Project
Ensure the vbox-server is active and the `vbox.sock` file exists. Then, deploy the CAPEv2 container using:
```bash
docker run -it \
    -v $(realpath ./vbox.sock):/opt/vbox/vbox.sock \
    -v $(realpath ./CAPEv2):/opt/CAPEv2 \
    --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN \
    --name cape cape:latest
```
This command runs the Docker container with several specific settings:
- **Volume Mounts**: Maps the `vbox.sock` file and the CAPEv2 directory from your host into the container. This integration is crucial for allowing the container to interface with the host's VirtualBox installation.
- **Network Settings**: Uses the host’s network directly (`--net=host`), enabling the container to communicate with the virtual machines managed by VirtualBox as if it were part of the host system.
- **Capabilities**: Adds `NET_RAW` and `NET_ADMIN` to allow the container to perform network captures and manage network settings, essential for dynamic analysis of malware.


### Sample Submission
Submit a malware sample to the container:
```bash
docker exec -it <container_id> bash -c 'python utils/submit.py /path/to/sample'
```

### Process Task
To process a task within the container:
```bash
docker exec -it <container_id> bash -c 'python utils/process.py <task_id>'
```
After processing is complete, you can find the sample analysis reports in the 'CAPEv2/storage/analysis/<task_id>/reports/' directory.


## Notice
Note that this project only sets up a basic CAPEv2 sandbox functionality. It allows for sample submission and scheduling of VirtualBox virtual machines for analysis, and generates analysis reports. This project does not include many components of the core CAPEv2, so you may encounter some errors during runtime, such as: 
```bash
[socket-aux] CRITICAL: Unable to passthrough root command (/tmp/cuckoo-rooter) as the rooter unix socket: inetsim_disable doesn't exist
```
I will continue to improve this project and integrate more components in the future to enhance the Dockerized functionality of CAPEv2.

