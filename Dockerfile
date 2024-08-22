# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata

# Install Python and other dependencies as root before switching to user
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    curl \
    gcc \
    g++ \
    make \
    libmagic1 \
    p7zip-full \
    git \
    tcpdump \
    sudo

# Use update-alternatives to set python3.10 as the default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Set the working directory to /home/cuckoo
WORKDIR /home/installer

# Copy the requirements file into the container at /home/cape
COPY CAPEv2/installer/* /home/installer

# Install CAPEv2
RUN chmod a+x ./cape2.sh \
    && ./cape2.sh base cape \
    && ./cape2.sh all cape

# Clean up
RUN rm -rf /home/installer

# Add the cape user to the sudo group
RUN usermod -aG sudo cape \
    && echo "cape ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cape

# Set the password for the cape user
RUN echo "cape:cape" | chpasswd

# Copy the entrypoint script into the container at /home/cape
COPY scripts/entrypoint.sh /home/cape/entrypoint.sh
COPY scripts/cape-entry.service /etc/systemd/system/cape-entry.service

# enable the service
RUN systemctl enable cape-entry.service

USER cape

# Set the working directory to /opt/CAPEv2
WORKDIR /opt/CAPEv2

# Install dependencies
RUN poetry install

# Install libvirt
RUN sudo apt update \
    && sudo apt install -y libvirt-clients \
    libvirt-dev \
    mlocate \
    && sudo updatedb 

# Install libvirt modules
RUN sudo -u cape poetry run extra/libvirt_installer.sh

USER  root

ENTRYPOINT ["/usr/sbin/init"]

