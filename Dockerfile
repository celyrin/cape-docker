# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

ENV TZ=UTC

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

# Install VirtualBox
COPY bin/vbox-client /usr/bin/VBoxManage

# Set the working directory to /opt/CAPEv2
WORKDIR /opt/CAPEv2

# Clean up
RUN rm -rf /home/installer

# Install entrypoint
COPY entrypoint.sh /home/cape/entrypoint.sh

ENTRYPOINT ["/home/cape/entrypoint.sh"]
