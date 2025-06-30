package main

// This file tests auto-import functionality
// Try typing these functions and see if imports are suggested:
// - fmt.Println() -> should suggest importing "fmt"
// - json.Marshal() -> should suggest importing "encoding/json"
// - http.Get() -> should suggest importing "net/http"
// - time.Now() -> should suggest importing "time"

func main() {
	// TODO: Test auto-import by typing these without imports:
	// fmt.Println("Hello, World!")
	// json.Marshal(map[string]string{"key": "value"})
	// http.Get("https://example.com")
	// time.Now()
	
	name := "Go Developer"
	println("Welcome,", name)
}