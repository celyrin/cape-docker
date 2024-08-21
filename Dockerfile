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
    && ./cape2.sh all cape \
    && sudo -u cape poetry install

# Install VirtualBox
COPY bin/vbox-client /usr/bin/VBoxManage

# Clean up
RUN rm -rf /home/installer

# Add cape user
RUN echo "cape ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cape

# Copy the entrypoint script into the container at /home/cape
COPY scripts/entrypoint.sh /home/cape/entrypoint.sh
COPY scripts/cape-entry.service /etc/systemd/system/cape-entry.service

# enable the service
RUN systemctl enable cape-entry.service

# Set the working directory to /opt/CAPEv2
WORKDIR /opt/CAPEv2

ENTRYPOINT ["/usr/sbin/init"]

