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
    sudo

# Use update-alternatives to set python3.10 as the default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Create cape user with no password and add to sudo group
RUN adduser --disabled-password --gecos "" cape && \
    usermod -aG sudo cape

# Switch to cape user
USER cape

# Download and install pip for Python
RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
RUN python /tmp/get-pip.py
RUN rm /tmp/get-pip.py

# Install Python dependencies
RUN python -m pip install --upgrade pip && \
    python -m pip install --upgrade setuptools

# # Set the working directory to /home/cuckoo
WORKDIR /home/cape

# Copy the requirements file into the container at /home/cape
COPY CAPEv2/requirements.txt /home/cape

# Install Python dependencies
RUN python -m pip install -r requirements.txt

COPY bin/vbox-client /usr/bin/VBoxManage

# Set the entrypoint to cuckoo
CMD ["bash"]