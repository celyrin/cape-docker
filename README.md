# cape-docker
Deploy [CAPEv2 Sandbox](https://github.com/kevoreilly/CAPEv2.git) within a Docker container for efficient malware analysis.

## Overview
This repository contains all the necessary configurations to deploy the CAPEv2 malware analysis system using Docker. The setup includes orchestrating the communication between the CAPEv2 container and VirtualBox installed on the host machine through custom vbox-server and vbox-client components. It also enables network capture using tcpdump within the container which communicates with the guest VMs on the host’s network.
In addition to VirtualBox, I have created a [branch](https://github.com/celyrin/cape-docker/tree/kvm) that supports virtualization using KVM. You can refer to this [README](https://github.com/celyrin/cape-docker/blob/kvm/README.md) for configuration and usage details.
Additionally, I have provided a [branch](https://github.com/celyrin/cape-docker/tree/base) that implements the containerization of CAPE's basic functionalities. In this branch, VirtualBox is used for virtualization, and the container includes the necessary dependencies for running the CAPE sandbox. You can submit samples and retrieve analysis reports. For detailed information, refer to this [README](https://github.com/celyrin/cape-docker/blob/base/README.md).

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


## Running the Project
To successfully run the CAPEv2 environment, ensure that the VirtualBox service (`vbox-server`) is active and the `vbox.sock` file exists on your host. Use the following Docker command to deploy the CAPEv2 container:

```bash
docker run -it \
    -v $(realpath ./vbox.sock):/opt/vbox/vbox.sock \
    --cap-add SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cgroupns=host\
    --tmpfs /run --tmpfs /run/lock \
    --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN \
    --cap-add=SYS_NICE -v $(realpath ./work):/work \
    --name cape celyrin/cape:latest
```

### Detailed Explanation of Docker Command
This command configures the Docker container with specific settings vital for running CAPEv2 effectively:

- **Volume Mounts**:
  - `$(realpath ./vbox.sock):/opt/vbox/vbox.sock`: Maps the `vbox.sock` Unix socket from the host into the container. This socket is essential for the container to communicate with VirtualBox, managing virtual machine operations.
  - `$(realpath ./work):/work`: Mounts a host directory `work` into the container at `/work`. This directory typically stores configuration files, logs, and persistent data, ensuring that important data is retained across container restarts.

- **Mounting cgroup**:
  - `sys/fs/cgroup:/sys/fs/cgroup:rw`: Attaches the host’s control group filesystem (`cgroup`) in read-write mode. This is necessary for `systemd` to manage system and service processes effectively within the container.
  - `--cgroupns=host`: Shares the host’s cgroup namespace with the container. This setting is essential for `systemd` to manage cgroups effectively and orchestrate resources within the container.

- **Temporary Filesystems**:
  - `--tmpfs /run --tmpfs /run/lock`: Creates temporary filesystems for `/run` and `/run/lock`. These are crucial for the operation of `systemd` and other processes that need volatile memory locations for runtime and locking mechanisms, which are not persisted after container shutdown.

- **Network Settings**:
  - `--net=host`: Uses the host’s networking stack. This setting is critical for cases where the container needs to directly manage network traffic, such as interfacing with network applications or managing virtual machines that require seamless network integration.

- **Capabilities**:
  - `SYS_ADMIN`: Grants administrative privileges, necessary for many of `systemd`'s functions within the container.
  - `NET_RAW` and `NET_ADMIN`: These capabilities are essential for network traffic capturing and manipulation. They enable the container to perform tasks like packet sniffing and network interface configuration—key for dynamic malware analysis.
  - `SYS_NICE`: Allows the container to adjust the niceness (priority) of processes, which helps in resource allocation and optimization during intensive tasks.


## Configuring CAPE
If you are running for the first time, you can use an empty work directory. After the container starts, it will move the CAPE configuration files from the CAPE working directory to the work directory and create symbolic links. You can then make the necessary modifications in the work/conf directory and restart the service.

Modify `cuckoo.conf` to use VirtualBox:
```bash
cuckoo.machinery=virtualbox
```

Specify the result server IP in `cuckoo.conf`. Use the IP address of vboxnet0 or other VirtualBox network cards in the host machine:
```bash
resultserver.ip=<ip_of_host>
```

Follow the [official documentation](https://capev2.readthedocs.io/en/latest/installation/guest/index.html) to configure guest VMs in `virtualbox.conf`.

Configure the network interface in `auxiliary.conf`:
Since we are using VirtualBox, you need to change the default KVM network interface virbr0 to vboxnet0 (depending on which interface you have configured). This way, we can use tcpdump to capture traffic.
```bash
sniffer.interface=vboxnet0
```


## Usage Guide

### Getting Started
After starting the CAPEv2 container, you can log into the system using the credentials (typically `cape` for both username and password). This allows you to manage services and submit malware samples for analysis. Ensure that your Docker container is properly configured and that you are ready to use CAPEv2's powerful features for dynamic malware analysis.

### Service Management
Before diving into sample submission or analysis, it's crucial to check the status of the following services to ensure they are active:
- **cape.service**
- **cape-web.service**
- **cape-processor.service**

Use the following command to check the status of these services:
```bash
systemctl status <service-name>
```
If any of these services aren't running, you'll need to inspect the logs for potential issues and restart the service using:
```bash
systemctl restart <service-name>
```

### Sample Submission
To submit a malware sample for analysis, ensure your working directory is `/opt/CAPEv2` within the container. Use the following command to submit a sample:
```bash
poetry run python utils/submit.py /path/to/sample
```

### Processing Tasks
To process a task based on its ID, use the following command:
```bash
poetry run python utils/process.py -r <task_id>
```

### Using CAPE from Outside the Container
If you prefer to execute commands from outside the container, use the following syntax:
```bash
docker exec -it -u cape cape bash -c '<command>'
```
This allows you to manage the container's internal operations from your host machine's command line.

### Accessing the Web Interface
CAPEv2 also features a web interface for easier management and monitoring of tasks. Since the container is started with the host's network, you can access the web interface by navigating to:
```
http://localhost:8000
```
This direct access simplifies interactions with CAPE's GUI, making it straightforward to submit samples, check their status, and analyze results.

### General Tips
- Always ensure that the required services are active before proceeding with sample submissions or task processing.
- Regularly check service logs if you encounter issues with the functionalities of CAPE.
- For a smoother experience, familiarize yourself with the basic commands and operational procedures outlined above.


## Notice
This project is currently under development and may have some issues. If you have any questions, please open an issue in the [GitHub repository](https://github.com/celyrin/cape-docker/issues) or contact me via email at celyrin6@gmail.com.
