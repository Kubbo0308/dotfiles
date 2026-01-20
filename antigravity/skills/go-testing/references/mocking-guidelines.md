# Mocking Best Practices in Go

Proper mocking ensures your tests are reliable, maintainable, and actually verify the behavior you intend to test.

## Critical Rule: Avoid `gomock.Any()`

**NEVER use `gomock.Any()` when you can specify the exact expected value.**

Using `gomock.Any()` weakens your tests by not verifying the actual arguments passed to mocked methods.

### Why This Matters

```go
// BAD: This test will pass even if wrong data is sent
mockRepo.EXPECT().
    CreateUser(gomock.Any()).
    Return(nil)

// This bug would go undetected:
// service.CreateUser(User{Name: "wrong"}) // passes anyway!

// GOOD: Explicit expectation catches bugs
mockRepo.EXPECT().
    CreateUser(User{
        Name:  "John",
        Email: "john@example.com",
    }).
    Return(nil)
```

## When `gomock.Any()` Is Acceptable

Only use `gomock.Any()` in these specific situations:

### 1. Context parameters

```go
// OK: Context is typically not worth matching
mockRepo.EXPECT().
    GetUser(gomock.Any(), userID).  // context
    Return(user, nil)
```

### 2. Dynamically generated values you cannot predict

```go
// OK: UUID is generated inside the function
mockRepo.EXPECT().
    CreateUser(gomock.Any()).  // contains generated UUID
    DoAndReturn(func(u User) error {
        // Validate specific fields instead
        if u.Name != "John" {
            return errors.New("unexpected name")
        }
        return nil
    })
```

### 3. Time-based values

```go
// OK: Timestamp is generated at runtime
mockRepo.EXPECT().
    SaveEvent(gomock.Any()).  // contains time.Now()
    Return(nil)
```

## Better Alternatives to `gomock.Any()`

### Use Custom Matchers

```go
// Create a matcher for partial validation
type userMatcher struct {
    name  string
    email string
}

func (m userMatcher) Matches(x interface{}) bool {
    u, ok := x.(User)
    if !ok {
        return false
    }
    return u.Name == m.name && u.Email == m.email
}

func (m userMatcher) String() string {
    return fmt.Sprintf("User{Name: %s, Email: %s}", m.name, m.email)
}

// Usage
mockRepo.EXPECT().
    CreateUser(userMatcher{name: "John", email: "john@example.com"}).
    Return(nil)
```

### Use `DoAndReturn` for Complex Validation

```go
mockRepo.EXPECT().
    CreateUser(gomock.Any()).
    DoAndReturn(func(u User) error {
        assert.Equal(t, "John", u.Name)
        assert.Equal(t, "john@example.com", u.Email)
        assert.NotEmpty(t, u.ID)  // validate generated field
        return nil
    })
```

## Interface-Based Mocking

### Define Small Interfaces

```go
// BAD: Large interface is hard to mock
type Database interface {
    GetUser(id int) (*User, error)
    CreateUser(u User) error
    UpdateUser(u User) error
    DeleteUser(id int) error
    GetAllUsers() ([]User, error)
    // ... 20 more methods
}

// GOOD: Small, focused interfaces
type UserReader interface {
    GetUser(id int) (*User, error)
}

type UserWriter interface {
    CreateUser(u User) error
}

// Compose when needed
type UserRepository interface {
    UserReader
    UserWriter
}
```

### Use Constructor Injection

```go
// GOOD: Dependencies are injected
type UserService struct {
    repo UserRepository
}

func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}

// Test with mock
func TestUserService_Create(t *testing.T) {
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    mockRepo := NewMockUserRepository(ctrl)
    service := NewUserService(mockRepo)

    // ... test logic
}
```

## Testify Mock Alternative

If using testify/mock instead of gomock:

```go
type MockRepository struct {
    mock.Mock
}

func (m *MockRepository) GetUser(id int) (*User, error) {
    args := m.Called(id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*User), args.Error(1)
}

// Usage
func TestGetUser(t *testing.T) {
    mockRepo := new(MockRepository)

    // Explicit expectations
    mockRepo.On("GetUser", 123).Return(&User{ID: 123, Name: "John"}, nil)

    // NOT: mockRepo.On("GetUser", mock.Anything).Return(...)
}
```

## Summary

| Situation | Recommendation |
|-----------|----------------|
| Known, predictable values | Use exact values |
| Context parameters | `gomock.Any()` acceptable |
| Generated UUIDs/timestamps | Use `DoAndReturn` or custom matcher |
| Complex objects | Use custom matcher for key fields |
| Partial validation needed | Use `DoAndReturn` with assertions |

**Default behavior**: Always start with explicit values. Only relax to `Any()` when you have a specific reason.

