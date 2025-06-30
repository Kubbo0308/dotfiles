// TypeScript example showcasing colorful syntax highlighting
import React, { useState, useEffect, useCallback } from 'react';
import axios, { AxiosResponse } from 'axios';

// Interface definitions with various types
interface User {
  id: number;
  name: string;
  email: string;
  createdAt: Date;
  isActive: boolean;
  profile?: UserProfile;
}

interface UserProfile {
  avatar: string;
  bio: string;
  preferences: {
    theme: 'light' | 'dark' | 'auto';
    notifications: boolean;
    language: string;
  };
}

// Type aliases and union types
type ApiResponse<T> = {
  success: true;
  data: T;
} | {
  success: false;
  error: string;
};

type UserStatus = 'active' | 'inactive' | 'pending' | 'suspended';
type Theme = 'light' | 'dark' | 'auto';

// Generic utility type
type Partial<T> = {
  [P in keyof T]?: T[P];
};

// Constants with various data types
const API_BASE_URL = 'https://api.example.com/v1';
const MAX_RETRIES = 3;
const TIMEOUT_MS = 5000;
const DEFAULT_PAGE_SIZE = 20;

// Color values for testing colorizer
const COLORS = {
  primary: '#007bff',
  secondary: '#6c757d',
  success: '#28a745',
  danger: '#dc3545',
  warning: '#ffc107',
  info: '#17a2b8',
  background: '#f8f9fa',
  text: '#212529',
} as const;

// Enum for user roles
enum UserRole {
  ADMIN = 'admin',
  MODERATOR = 'moderator',
  USER = 'user',
  GUEST = 'guest',
}

// Class with various method types
class UserService {
  private apiClient: axios.AxiosInstance;
  private cache: Map<number, User> = new Map();

  constructor(baseURL: string = API_BASE_URL) {
    this.apiClient = axios.create({
      baseURL,
      timeout: TIMEOUT_MS,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  // Async method with error handling
  async getUser(id: number): Promise<ApiResponse<User>> {
    try {
      // Check cache first
      const cachedUser = this.cache.get(id);
      if (cachedUser) {
        return { success: true, data: cachedUser };
      }

      const response: AxiosResponse<User> = await this.apiClient.get(`/users/${id}`);
      const user = response.data;
      
      // Cache the result
      this.cache.set(id, user);
      
      return { success: true, data: user };
    } catch (error) {
      console.error('Failed to fetch user:', error);
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Unknown error' 
      };
    }
  }

  // Method with optional parameters and default values
  async getUsers(
    page: number = 1,
    pageSize: number = DEFAULT_PAGE_SIZE,
    filters?: Partial<User>
  ): Promise<ApiResponse<User[]>> {
    try {
      const params = new URLSearchParams({
        page: page.toString(),
        pageSize: pageSize.toString(),
        ...filters && { filters: JSON.stringify(filters) },
      });

      const response: AxiosResponse<User[]> = await this.apiClient.get(`/users?${params}`);
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Failed to fetch users' 
      };
    }
  }

  // Method with complex return type
  async createUser(userData: Omit<User, 'id' | 'createdAt'>): Promise<ApiResponse<User>> {
    try {
      const response: AxiosResponse<User> = await this.apiClient.post('/users', {
        ...userData,
        createdAt: new Date().toISOString(),
      });

      const newUser = response.data;
      this.cache.set(newUser.id, newUser);
      
      return { success: true, data: newUser };
    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Failed to create user' 
      };
    }
  }

  // Private helper method
  private clearCache(): void {
    this.cache.clear();
    console.log('User cache cleared');
  }

  // Static method
  static validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}

// React functional component with hooks
interface UserListProps {
  initialUsers?: User[];
  onUserSelect?: (user: User) => void;
  theme?: Theme;
}

const UserList: React.FC<UserListProps> = ({ 
  initialUsers = [], 
  onUserSelect,
  theme = 'light' 
}) => {
  // State hooks with various types
  const [users, setUsers] = useState<User[]>(initialUsers);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>('');

  // Service instance
  const userService = new UserService();

  // Memoized callback
  const handleUserClick = useCallback((user: User) => {
    setSelectedUser(user);
    onUserSelect?.(user);
  }, [onUserSelect]);

  // Effect hook with async operations
  useEffect(() => {
    const fetchUsers = async () => {
      setLoading(true);
      setError(null);

      const result = await userService.getUsers();
      
      if (result.success) {
        setUsers(result.data);
      } else {
        setError(result.error);
      }
      
      setLoading(false);
    };

    fetchUsers();
  }, []);

  // Computed value with filtering
  const filteredUsers = users.filter(user => 
    user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Conditional rendering with JSX
  if (loading) {
    return <div className="loading">Loading users...</div>;
  }

  if (error) {
    return <div className="error" style={{ color: COLORS.danger }}>Error: {error}</div>;
  }

  return (
    <div className={`user-list theme-${theme}`} style={{ backgroundColor: COLORS.background }}>
      <div className="search-container">
        <input
          type="text"
          placeholder="Search users..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          style={{ 
            borderColor: COLORS.primary,
            color: COLORS.text 
          }}
        />
      </div>
      
      <div className="user-grid">
        {filteredUsers.map((user) => (
          <div
            key={user.id}
            className={`user-card ${selectedUser?.id === user.id ? 'selected' : ''}`}
            onClick={() => handleUserClick(user)}
            style={{
              borderColor: selectedUser?.id === user.id ? COLORS.primary : COLORS.secondary,
              backgroundColor: user.isActive ? COLORS.success : COLORS.warning,
            }}
          >
            <h3 style={{ color: COLORS.text }}>{user.name}</h3>
            <p style={{ color: COLORS.text }}>{user.email}</p>
            <span className={`status ${user.isActive ? 'active' : 'inactive'}`}>
              {user.isActive ? 'Active' : 'Inactive'}
            </span>
          </div>
        ))}
      </div>

      {filteredUsers.length === 0 && (
        <div className="no-results" style={{ color: COLORS.info }}>
          No users found matching "{searchTerm}"
        </div>
      )}
    </div>
  );
};

// Higher-order component with generics
function withLoading<P extends object>(
  Component: React.ComponentType<P>
): React.FC<P & { isLoading?: boolean }> {
  return ({ isLoading, ...props }) => {
    if (isLoading) {
      return <div className="loading-spinner">Loading...</div>;
    }
    return <Component {...props as P} />;
  };
}

// Example usage with destructuring and spread operator
const EnhancedUserList = withLoading(UserList);

// Export statements
export { UserService, UserList, EnhancedUserList };
export type { User, UserProfile, ApiResponse, UserStatus, Theme };
export default UserList;