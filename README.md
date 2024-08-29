# cape-docker
Deploy [CAPEv2 Sandbox](https://github.com/kevoreilly/CAPEv2.git) within a Docker container for efficient malware analysis using KVM.

## Overview
This Docker setup provides a streamlined process for deploying the CAPEv2 Sandbox for malware analysis, leveraging the power of KVM for virtualization. By encapsulating CAPEv2 within Docker, users can benefit from simplified installation and configuration, while maintaining robust analysis capabilities. This setup is ideal for both development and production environments where quick deployment and isolation are critical.

## Prerequisites
- Docker
- KVM enabled on the host

## Building the Project
Run the following command in the project directory to build the CAPEv2 Docker image:

```bash
make all
```

This command compiles the necessary binaries and builds the CAPEv2 Docker image tagged as `cape:kvm`.
If you don't want to build the project yourself, you can download the latest release package from the [Releases](https://github.com/celyrin/cape-docker/releases) section.


## Preparing to Run
Ensure that KVM is properly set up and accessible on your host. And make sure the guest machine is ready to be used by CAPEv2. You can follow the [official documentation](https://capev2.readthedocs.io/en/latest/installation/guest/index.html) to set up the guest machine.


## Running the Project
To successfully run the CAPEv2 environment, use the following Docker command to deploy the CAPEv2 container with KVM support:

```bash
docker run -it \
    --cap-add SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cgroupns=host\
    --tmpfs /run --tmpfs /run/lock \
    --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN \
    --cap-add=SYS_NICE -v $(realpath ./work):/work \
    --device /dev/kvm  -v /var/run/libvirt:/var/run/libvirt \
    --name cape celyrin/cape:kvm
```

### Detailed Explanation of Docker Command
This command configures the Docker container with specific settings vital for running CAPEv2 effectively using KVM:

- **Volume Mounts**:
  - `$(realpath ./work):/work`: Mounts a host directory `work` into the container at `/work`. This directory typically stores configuration files, logs, and persistent data, ensuring that important data is retained across container restarts.
  - `/var/run/libvirt:/var/run/libvirt`: Maps the host’s libvirt socket to the container. This socket is crucial for managing virtual machines using KVM within the container.

- **Mounting cgroup**:
  - `sys/fs/cgroup:/sys/fs/cgroup:rw`: Attaches the host’s control group filesystem (`cgroup`) in read-write mode. This is necessary for `systemd` to manage system and service processes effectively within the container.
  - `--cgroupns=host`: Shares the host’s cgroup namespace with the container. This setting is essential for `systemd` to manage cgroups effectively and orchestrate resources within the container.

- **Device Mapping**:
  - `/dev/kvm`: Maps the `/dev/kvm` device from the host to the container. This device is essential for KVM-based virtualization, allowing the container to create and manage virtual machines using the host’s KVM capabilities.

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
cuckoo.machinery=kvm
```

Specify the result server IP in `cuckoo.conf`. Use the IP address of virbr0 or other KVM network cards in the host machine:
```bash
resultserver.ip=<ip_of_host>
```

Follow the [official documentation](https://capev2.readthedocs.io/en/latest/installation/index.html) to configure guest VMs in kvm.conf.

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
