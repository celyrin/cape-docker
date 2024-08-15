# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Install Python and other dependencies as root before switching to user
RUN apt-get update && apt-get install -y \
    python3.10 \
    python-pip \
    curl \
    sudo

# Create cape user with no password and add to sudo group
RUN adduser --disabled-password --gecos "" cape && \
    usermod -aG sudo cape

# Switch to cape user
USER cape

# Ensure the user cuckoo can access Python and pip
ENV PATH=$PATH:/usr/bin:/home/cuckoo/.local/bin

COPY CAPEv2/requirements.txt /home/cape

RUN pip install -r requirements.txt

COPY bin/vbox-client /usr/bin/VBoxManage

# Set the working directory to /home/cuckoo
WORKDIR /home/cape

# Set the entrypoint to cuckoo
CMD ["bash"]