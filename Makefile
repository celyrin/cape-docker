# Specify the shell environment for make
SHELL := /bin/bash

# Default target
all: docker-build

# Build Docker image
docker-build:
	@echo "Building Docker image..."
	@docker build -t cape:kvm .

# Declare phony targets
.PHONY: all docker-build
