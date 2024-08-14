package main

import (
	"fmt"
	"net"
	"os"
	"strings"
)

func main() {
	// Check if any command is passed
	if len(os.Args) < 2 {
		fmt.Println("Usage: client <vboxmanage commands>")
		return
	}

	// Join the arguments to form the command
	command := strings.Join(os.Args[1:], " ")

	// Connect to the Unix socket
	conn, err := net.Dial("unix", "/opt/vbox/vbox.sock")
	if err != nil {
		fmt.Println("Error connecting:", err.Error())
		return
	}
	defer conn.Close()

	// Send command to the server
	_, err = conn.Write([]byte(command + "\n"))
	if err != nil {
		fmt.Println("Error sending command:", err.Error())
		return
	}

	// Receive the response
	response := make([]byte, 4096) // buffer size
	n, err := conn.Read(response)
	if err != nil {
		fmt.Println("Error reading response:", err.Error())
		return
	}

	fmt.Print(string(response[:n]))
}
