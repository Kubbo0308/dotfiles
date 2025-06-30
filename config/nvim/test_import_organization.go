package main

// This file tests import organization
// The imports below are deliberately unorganized and include unused imports
import (
	"encoding/json"
	"net/http"
	"fmt"
	"os"
	"time"
	"context"  // unused import - should be removed
	"strings"
)

type User struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

func main() {
	// Using some of the imported packages
	user := User{ID: 1, Name: "Test User"}
	
	// JSON marshaling
	data, err := json.Marshal(user)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	
	// HTTP request
	resp, err := http.Get("https://jsonplaceholder.typicode.com/users/1")
	if err != nil {
		fmt.Printf("HTTP Error: %v\n", err)
		return
	}
	defer resp.Body.Close()
	
	// String manipulation
	result := strings.ToUpper(string(data))
	fmt.Println("Response:", result)
	
	// Time usage
	fmt.Println("Current time:", time.Now().Format("2006-01-02 15:04:05"))
}