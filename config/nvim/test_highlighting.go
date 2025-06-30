package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

// User represents a user in the system
type User struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
	IsActive  bool      `json:"is_active"`
}

// UserService handles user-related operations
type UserService interface {
	GetUser(ctx context.Context, id int) (*User, error)
	CreateUser(ctx context.Context, user *User) error
	UpdateUser(ctx context.Context, user *User) error
	DeleteUser(ctx context.Context, id int) error
}

// userRepository implements UserService
type userRepository struct {
	users map[int]*User
}

// NewUserRepository creates a new user repository
func NewUserRepository() UserService {
	return &userRepository{
		users: make(map[int]*User),
	}
}

// GetUser retrieves a user by ID
func (r *userRepository) GetUser(ctx context.Context, id int) (*User, error) {
	if user, exists := r.users[id]; exists {
		return user, nil
	}
	return nil, fmt.Errorf("user with id %d not found", id)
}

// CreateUser creates a new user
func (r *userRepository) CreateUser(ctx context.Context, user *User) error {
	if user == nil {
		return fmt.Errorf("user cannot be nil")
	}
	
	// Generate ID if not provided
	if user.ID == 0 {
		user.ID = len(r.users) + 1
	}
	
	user.CreatedAt = time.Now()
	r.users[user.ID] = user
	
	log.Printf("Created user: %+v", user)
	return nil
}

// UpdateUser updates an existing user
func (r *userRepository) UpdateUser(ctx context.Context, user *User) error {
	if user == nil {
		return fmt.Errorf("user cannot be nil")
	}
	
	if _, exists := r.users[user.ID]; !exists {
		return fmt.Errorf("user with id %d not found", user.ID)
	}
	
	r.users[user.ID] = user
	return nil
}

// DeleteUser removes a user by ID
func (r *userRepository) DeleteUser(ctx context.Context, id int) error {
	if _, exists := r.users[id]; !exists {
		return fmt.Errorf("user with id %d not found", id)
	}
	
	delete(r.users, id)
	log.Printf("Deleted user with id: %d", id)
	return nil
}

// handleGetUser handles HTTP GET requests for users
func handleGetUser(service UserService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// This is a comment about the HTTP handler
		ctx := r.Context()
		
		// Parse user ID from URL (simplified)
		userID := 1 // In real code, parse from URL
		
		user, err := service.GetUser(ctx, userID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(user); err != nil {
			http.Error(w, "failed to encode response", http.StatusInternalServerError)
			return
		}
	}
}

// Constants for configuration
const (
	DefaultPort     = 8080
	MaxConnections  = 100
	TimeoutDuration = 30 * time.Second
	APIVersion      = "v1"
)

// Color codes for testing colorizer
var colors = []string{
	"#FF0000", // Red
	"#00FF00", // Green  
	"#0000FF", // Blue
	"#FFFF00", // Yellow
	"#FF00FF", // Magenta
	"#00FFFF", // Cyan
}

func main() {
	// Initialize user service
	userService := NewUserRepository()
	
	// Create sample users
	users := []*User{
		{Name: "Alice", Email: "alice@example.com", IsActive: true},
		{Name: "Bob", Email: "bob@example.com", IsActive: false},
		{Name: "Charlie", Email: "charlie@example.com", IsActive: true},
	}
	
	ctx := context.Background()
	for _, user := range users {
		if err := userService.CreateUser(ctx, user); err != nil {
			log.Fatalf("Failed to create user: %v", err)
		}
	}
	
	// Set up HTTP routes
	http.HandleFunc("/api/v1/users", handleGetUser(userService))
	
	// Server configuration
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", DefaultPort),
		ReadTimeout:  TimeoutDuration,
		WriteTimeout: TimeoutDuration,
		IdleTimeout:  TimeoutDuration,
	}
	
	log.Printf("Starting server on port %d", DefaultPort)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server failed to start: %v", err)
	}
}