package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"os/exec"
	"strings"
	"sync"
)

func main() {
	// Define the path for the Unix socket
	socketPath := "./vbox.sock"
	// Ensure any existing socket at this path is removed before starting
	os.Remove(socketPath)

	// Create a listener on the Unix socket path
	listen, err := net.Listen("unix", socketPath)
	if err != nil {
		fmt.Printf("Failed to listen on socket: %v\n", err)
		return
	}
	defer listen.Close() // Ensure the listener is closed when main() exits
	fmt.Println("Server listening on", socketPath)

	var wg sync.WaitGroup // Use a WaitGroup to wait for all go routines to finish

	// Infinite loop to accept all incoming connections
	for {
		conn, err := listen.Accept()
		if err != nil {
			fmt.Printf("Error accepting connection: %v\n", err)
			continue // Continue to the next iteration if there's an error
		}
		wg.Add(1)                   // Increment the WaitGroup counter
		go handleRequest(conn, &wg) // Handle each connection in a new goroutine
	}

	wg.Wait() // Block until all goroutines have finished
}

func handleRequest(conn net.Conn, wg *sync.WaitGroup) {
	defer wg.Done()    // Decrement the counter when the goroutine completes
	defer conn.Close() // Ensure the connection is closed on function exit

	// Read a message from the connection until the newline character
	message, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		fmt.Printf("Error reading: %v\n", err)
		return
	}
	fmt.Print("Received command: ", string(message))

	// Execute the vboxmanage command using the received message
	command := exec.Command("vboxmanage", strings.Fields(strings.TrimSpace(message))...)
	output, err := command.CombinedOutput()
	if err != nil {
		fmt.Printf("Error executing command: %v\n", err)
		conn.Write([]byte("Error executing command: " + err.Error() + "\n"))
		return
	}
	conn.Write(output) // Send the output back to the client
}
