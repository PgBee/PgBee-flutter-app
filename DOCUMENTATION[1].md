# PGBee Server - API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Environment Setup](#environment-setup)
4. [Database Models](#database-models)
5. [API Endpoints](#api-endpoints)
6. [Authentication & Authorization](#authentication--authorization)
7. [Middleware](#middleware)
8. [Deployment](#deployment)
9. [Development](#development)

## Overview

PGBee Server is a RESTful API backend for a hostel/PG (Paying Guest) management system. It's built with Node.js, Express.js, TypeScript, and PostgreSQL using Sequelize ORM. The application provides functionality for managing hostels, users, reviews, amenities, and owner operations.

### Key Features
- User authentication (JWT-based and Google OAuth)
- Hostel management
- Review system
- Amenities management
- Owner and student profiles
- Role-based access control
- RESTful API design
- Comprehensive error handling
- API documentation with Swagger

### Tech Stack
- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Sequelize
- **Authentication**: JWT, Passport.js (Google OAuth)
- **Validation**: Zod
- **Documentation**: Swagger/OpenAPI
- **Containerization**: Docker
- **Reverse Proxy**: Nginx

## Architecture

```
src/
├── config/          # Configuration files
├── controllers/     # Request handlers
├── middlewares/     # Custom middleware
├── models/          # Database models
├── routes/          # API routes
├── types/           # TypeScript type definitions
└── utils/           # Utility functions
```

## Environment Setup

### Required Environment Variables
```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=pgbee_db
DB_USER=your_db_user
DB_PASSWORD=your_db_password

# JWT Configuration
JWT_SECRET=your_jwt_secret
REFRESH_TOKEN=your_refresh_token_secret

# Server Configuration
PORT=3000
NODE_ENV=development

# Google OAuth (Optional)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

### Package Scripts
```bash
npm run dev          # Start development server with nodemon
npm run build        # Compile TypeScript to JavaScript
npm run start        # Start production server
npm run lint         # Run ESLint
npm run lint:fix     # Fix ESLint issues
npm run db:create    # Create database
npm run db:migrate   # Run database migrations
```

## Database Models

### 1. User Model
**Table**: `users`

Represents system users (both students and owners).

```typescript
interface UserAttributes {
  id: string;           // UUID primary key
  name: string;         // User's full name
  email: string;        // Unique email address
  password: string;     // Hashed password
  roleId?: string;      // Foreign key to Role model
  createdAt: Date;
  updatedAt: Date;
}
```

**Key Methods**:
- `findByEmail(email: string)`: Find user by email
- `createUser(userData)`: Create new user
- `verifyPassword(password)`: Verify password hash

### 2. Role Model
**Table**: `roles`

Defines user roles in the system.

```typescript
interface RoleAttributes {
  id: string;           // UUID primary key
  name: string;         // Role name (e.g., 'student', 'owner')
  createdAt: Date;
  updatedAt: Date;
}
```

### 3. Hostel Model
**Table**: `hostels`

Represents hostel/PG properties.

```typescript
interface HostelAttributes {
  id: string;           // UUID primary key
  hostelName: string;   // Name of the hostel
  phone: string;        // Contact phone
  address: string;      // Physical address
  curfew: boolean;      // Has curfew rules
  description: string;  // Detailed description
  distance: number;     // Distance from landmark
  location: string;     // Location area
  rent: number;         // Monthly rent
  gender: string;       // Gender restriction
  files: string;        // Image files (JSON/comma-separated)
  bedrooms: number;     // Number of bedrooms
  bathrooms: number;    // Number of bathrooms
  userId: string;       // Foreign key to User (owner)
  createdAt: Date;
  updatedAt: Date;
}
```

### 4. Review Model
**Table**: `reviews`

User reviews for hostels.

```typescript
interface ReviewAttributes {
  id: string;           // UUID primary key
  name: string;         // Reviewer name
  date: Date;           // Review date
  rating: number;       // Rating (1-5)
  text: string;         // Review text
  image: string;        // Review image
  userId: string;       // Foreign key to User
  hostelId: string;     // Foreign key to Hostel
  createdAt: Date;
  updatedAt: Date;
}
```

### 5. Amenities Model
**Table**: `amenities`

Hostel amenities and facilities.

```typescript
interface AmmenitiesAttributes {
  id: string;           // UUID primary key
  wifi: boolean;        // WiFi available
  ac: boolean;          // Air conditioning
  kitchen: boolean;     // Kitchen facility
  parking: boolean;     // Parking available
  laundry: boolean;     // Laundry service
  tv: boolean;          // TV available
  firstAid: boolean;    // First aid kit
  workspace: boolean;   // Study/work area
  security: boolean;    // Security features
  currentBill: boolean; // Electricity bill included
  waterBill: boolean;   // Water bill included
  food: boolean;        // Food service
  furniture: boolean;   // Furnished rooms
  bed: boolean;         // Bed provided
  water: boolean;       // Water supply
  studentsCount: number;// Current student count
  hostelId: string;     // Foreign key to Hostel
  createdAt: Date;
  updatedAt: Date;
}
```

### 6. Owner Model
**Table**: `owners`

Owner profile information.

```typescript
interface OwnerAttributes {
  id: string;           // UUID primary key
  name: string;         // Owner name
  phone: string;        // Contact phone
  createdAt: Date;
  updatedAt: Date;
}
```

### 7. Student Model
**Table**: `students`

Student profile information.

```typescript
interface StudentAttributes {
  id: string;              // UUID primary key
  userName: string;        // Username
  dob: Date;              // Date of birth
  country: string;        // Country
  permanentAddress: string; // Permanent address
  presentAddress: string;  // Current address
  city: string;           // City
  postalCode: string;     // Postal code
  createdAt: Date;
  updatedAt: Date;
}
```

### Database Relations

```
User (1) -> (1) Role
User (1) -> (0..1) Owner
User (1) -> (0..1) Student
User (1) -> (*) Hostel
User (1) -> (*) Review

Hostel (1) -> (*) Review
Hostel (1) -> (1) Amenities
```

## API Endpoints

### Authentication Routes (`/auth`)

#### POST `/auth/signup`
Register a new user.

**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "student"
}
```

**Response**:
```json
{
  "success": true,
  "message": "User created successfully",
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token"
}
```

#### POST `/auth/login`
User login.

**Request Body**:
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token"
}
```

#### POST `/auth/token/refresh`
Refresh access token.

#### GET `/auth/google`
Initiate Google OAuth login.

#### GET `/auth/google/callback`
Google OAuth callback handler.

### Hostel Routes (`/hostel`) 🔒
*All hostel routes require authentication*

#### POST `/hostel`
Create a new hostel.

**Request Body**:
```json
{
  "hostelName": "Green Valley PG",
  "phone": "9876543210",
  "address": "123 Main Street",
  "curfew": false,
  "description": "Modern PG with all facilities",
  "distance": 2.5,
  "location": "Central City",
  "rent": 8000,
  "gender": "mixed",
  "bedrooms": 2,
  "bathrooms": 2
}
```

#### GET `/hostel`
Get all hostels (for students).

#### GET `/hostel/user`
Get hostels owned by authenticated user.

#### PUT `/hostel/:id`
Update a hostel.

#### DELETE `/hostel/:id`
Delete a hostel.

### Review Routes (`/review`) 🔒
*All review routes require authentication*

#### POST `/review`
Create a review.

**Request Body**:
```json
{
  "name": "John Doe",
  "rating": 4,
  "text": "Great place to stay!",
  "date": "2025-01-15",
  "hostelId": "hostel_uuid"
}
```

#### GET `/review/user`
Get reviews by authenticated user.

#### GET `/review/review/hostel/:id`
Get reviews for a specific hostel.

#### GET `/review/:id`
Get a specific review.

#### PUT `/review/:id`
Update a review.

#### DELETE `/review/:id`
Delete a review.

### Amenities Routes (`/ammenities`) 🔒
*All amenities routes require authentication*

#### POST `/ammenities`
Create amenities for a hostel.

**Request Body**:
```json
{
  "wifi": true,
  "ac": false,
  "kitchen": true,
  "parking": true,
  "laundry": true,
  "tv": true,
  "firstAid": true,
  "workspace": true,
  "security": true,
  "currentBill": true,
  "waterBill": true,
  "food": false,
  "furniture": true,
  "bed": true,
  "water": true,
  "studentsCount": 10,
  "hostelId": "hostel_uuid"
}
```

#### GET `/ammenities/:id`
Get amenities for a hostel.

#### PUT `/ammenities/:id`
Update amenities.

#### DELETE `/ammenities/:id`
Delete amenities.

### Owner Routes (`/owner`) 🔒
*All owner routes require authentication*

#### POST `/owner/owners`
Register as owner.

#### GET `/owner/owners`
Get all owners.

#### GET `/owner/owners/:id`
Get owner by ID.

#### PUT `/owner/owners/:id`
Update owner profile.

#### DELETE `/owner/owners/:id`
Delete owner.

### Documentation Routes

#### GET `/docs`
Access Swagger UI documentation.

#### GET `/api-spec`
Get OpenAPI specification.

## Authentication & Authorization

### JWT Authentication
The application uses JWT (JSON Web Tokens) for authentication:

- **Access Token**: Short-lived (15 minutes), used for API requests
- **Refresh Token**: Long-lived (7 days), used to generate new access tokens

### Google OAuth
Google OAuth 2.0 integration for social login using Passport.js.

### Authorization Middleware
Protected routes require a valid JWT token in the Authorization header:
```
Authorization: Bearer <access_token>
```

### Session Configuration
Express sessions are configured for Google OAuth with the following settings:
- Session secret from environment
- Secure cookies in production
- HTTP-only cookies for security

## Middleware

### 1. Authentication Middleware (`authorize`)
- Validates JWT tokens
- Extracts user information
- Protects routes from unauthorized access

### 2. Error Handling Middleware
- Global error handler
- Structured error responses
- Logging of errors

### 3. Request Logger
- Logs all incoming requests
- Useful for debugging and monitoring

### 4. Not Found Handler
- Handles 404 errors for undefined routes

### 5. Exception Handlers
- `handleUncaughtException`: Catches uncaught exceptions
- `handleUnhandledRejection`: Catches unhandled promise rejections

## Deployment

### Docker Setup
The application includes Docker configuration:

#### Services:
1. **server-client**: Node.js application
2. **postgres-dev**: PostgreSQL database
3. **nginx**: Reverse proxy and load balancer
4. **certbot**: SSL certificate management

#### Ports:
- Application: `8080:8080`
- Database: `5432:5432`
- HTTP: `80:80`
- HTTPS: `443:443`

### Nginx Configuration
- Reverse proxy setup
- SSL termination
- Static file serving
- Load balancing (if scaled)

### SSL/TLS
- Let's Encrypt integration via Certbot
- Automatic certificate renewal
- HTTPS redirection

## Development

### Code Quality
- **ESLint**: Code linting with TypeScript support
- **Prettier**: Code formatting
- **Husky**: Git hooks for pre-commit linting
- **lint-staged**: Run linters on staged files

### Database Migrations
Sequelize CLI is used for database migrations:

```bash
# Create a new migration
npm run migration:generate -- --name create-new-table

# Run migrations
npm run db:migrate

# Undo last migration
npm run migrate:undo

# Undo all migrations
npm run migrate:undo:all
```

### Development Commands
```bash
# Start development server
npm run dev

# Run linting
npm run lint

# Fix linting issues
npm run lint:fix

# Build for production
npm run build
```

### Project Structure Best Practices

1. **Controllers**: Handle HTTP requests and responses
2. **Models**: Define data structures and database interactions
3. **Routes**: Define API endpoints and route handlers
4. **Middleware**: Handle cross-cutting concerns
5. **Utils**: Common utility functions and configurations
6. **Types**: TypeScript type definitions

### Error Handling Strategy

1. **Try-Catch Blocks**: Wrap async operations
2. **Error Middleware**: Global error handling
3. **Structured Responses**: Consistent error response format
4. **Logging**: Comprehensive error logging
5. **Status Codes**: Appropriate HTTP status codes

### Security Considerations

1. **Password Hashing**: bcrypt for password security
2. **JWT Security**: Short-lived access tokens
3. **CORS Configuration**: Restricted origins
4. **Input Validation**: Zod schema validation
5. **SQL Injection Prevention**: Sequelize ORM protection
6. **Environment Variables**: Sensitive data protection

### Performance Optimization

1. **Database Indexing**: Proper database indexes
2. **Connection Pooling**: Database connection optimization
3. **Caching Strategy**: Future implementation consideration
4. **Pagination**: Large dataset handling
5. **Compression**: Response compression (Nginx)

### Monitoring and Logging

1. **Request Logging**: All HTTP requests logged
2. **Error Logging**: Comprehensive error tracking
3. **Database Logging**: Connection and query monitoring
4. **Performance Metrics**: Response time tracking

This documentation provides a comprehensive overview of the PGBee Server codebase. For specific implementation details, refer to the source code in the respective modules.
