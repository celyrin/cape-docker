# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

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

# Copy the requirements file into the container at /home/cape
COPY CAPEv2/installer /home


# Set the working directory to /home/cuckoo
WORKDIR /home/cape/installer

RUN chmod a+x ./cape2.sh \
    && ./cape2.sh base cape | tee cape.log \
    && ./cape2.sh all cape | tee cape.log

# Install VirtualBox
COPY bin/vbox-client /usr/bin/VBoxManage

# Set the working directory to /opt/CAPEv2
WORKDIR /opt/CAPEv2

# Install entrypoint
COPY entrypoint.sh /home/cape/entrypoint.sh

ENTRYPOINT ["/home/cape/entrypoint.sh"]
