# Security Review Guide

## Table of Contents
1. [Input Validation](#input-validation)
2. [Authentication & Authorization](#authentication--authorization)
3. [Data Protection](#data-protection)
4. [Common Vulnerabilities](#common-vulnerabilities)

---

## Input Validation

### Check For
- All user input is validated on server-side
- Input length limits are enforced
- Input type/format is verified
- File uploads are restricted by type and size

### Red Flags
```javascript
// Bad: direct use of user input
const query = `SELECT * FROM users WHERE id = ${req.params.id}`;

// Good: parameterized query
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [req.params.id]);
```

## Authentication & Authorization

### Check For
- Authentication required for sensitive endpoints
- Authorization checks on every request
- Session management is secure
- Password requirements are enforced
- Rate limiting on auth endpoints

### Red Flags
- Hardcoded credentials
- Missing auth middleware
- Role checks only on frontend
- JWT without expiration

## Data Protection

### Check For
- Sensitive data is encrypted at rest
- HTTPS is enforced
- Passwords are hashed (bcrypt, argon2)
- API keys are in environment variables
- Logs don't contain sensitive data

### Red Flags
```javascript
// Bad: logging sensitive data
console.log(`User login: ${email}, password: ${password}`);

// Bad: hardcoded secret
const API_KEY = 'sk-1234567890';

// Good: environment variable
const API_KEY = process.env.API_KEY;
```

## Common Vulnerabilities

### SQL Injection
- Use parameterized queries
- Use ORM with proper escaping
- Never concatenate user input into queries

### XSS (Cross-Site Scripting)
- Escape HTML output
- Use Content Security Policy
- Sanitize rich text input

### CSRF (Cross-Site Request Forgery)
- Use CSRF tokens
- Validate Origin/Referer headers
- Use SameSite cookies

### Insecure Deserialization
- Validate serialized data
- Use safe serialization formats (JSON)
- Avoid deserializing untrusted data

