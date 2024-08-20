# Specify the shell environment for make
SHELL := /bin/bash

# Directory for output binary files
BIN_DIR := bin

# Default target
all: vbox-server vbox-client docker-build

# Build vbox-server binary
vbox-server: 
	@echo "Building vbox-server..."
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-extldflags "-static"' -o $(BIN_DIR)/vbox-server vbox-server.go

# Build vbox-client binary
vbox-client:
	@echo "Building vbox-client..."
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-extldflags "-static"' -o $(BIN_DIR)/vbox-client vbox-client.go

# Build Docker image
docker-build:
	@echo "Building Docker image..."
	@docker build -t cape .

# Clean up binaries and temporary files
clean:
	@echo "Cleaning up..."
	@rm -rf $(BIN_DIR)

# Declare phony targets
.PHONY: all vbox-server vbox-client docker-build clean
