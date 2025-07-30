# PGBee Server API Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture & Technology Stack](#architecture--technology-stack)
3. [Database Models](#database-models)
4. [API Endpoints](#api-endpoints)
5. [Authentication & Authorization](#authentication--authorization)
6. [Middleware](#middleware)
7. [Utilities & Configuration](#utilities--configuration)
8. [Error Handling](#error-handling)
9. [Database Configuration](#database-configuration)
10. [Development Setup](#development-setup)
11. [Docker Configuration](#docker-configuration)

## Project Overview

PGBee is a hostel booking application backend API built with Node.js, Express, TypeScript, and PostgreSQL. The application provides comprehensive functionality for managing hostels, users, reviews, amenities, and bookings. It supports multiple user roles (students, owners, admin) and includes Google OAuth authentication.

### Key Features
- User authentication (JWT + Google OAuth)
- Role-based access control
- Hostel management
- Review system
- Amenities management
- CAPTCHA verification
- Comprehensive logging
- API documentation with Swagger/RapiDoc
- Database migrations with Sequelize

## Architecture & Technology Stack

### Backend Technologies
- **Runtime**: Node.js
- **Framework**: Express.js v5.1.0
- **Language**: TypeScript
- **ORM**: Sequelize v6.37.7
- **Database**: PostgreSQL
- **Authentication**: Passport.js (Google OAuth), JWT
- **Validation**: Zod
- **Documentation**: Swagger + RapiDoc

### Development Tools
- **Package Manager**: pnpm
- **Process Manager**: Nodemon
- **Build Tool**: TypeScript Compiler (tsc)
- **Linting**: ESLint + Prettier
- **Git Hooks**: Husky + lint-staged
- **Containerization**: Docker

## Database Models

### User Model (`user-model.ts`)
Represents system users (students, owners, admins).

**Attributes:**
- `id` (UUID, Primary Key)
- `name` (String, Required)
- `email` (String, Required, Unique)
- `password` (String, Required, Hashed with bcrypt)
- `roleId` (UUID, Foreign Key to Role)
- `createdAt` (Date)
- `updatedAt` (Date)

**Methods:**
- `verifyPassword(password: string)` - Compares hashed password
- `findByEmail(email: string)` - Static method to find user by email
- `createUser(userData)` - Static method to create new user

**Relationships:**
- Belongs to Role
- Has one Owner (if role is owner)
- Has one Student (if role is student)
- Has many Hostels (if role is owner)
- Has many Reviews

### Role Model (`role-model.ts`)
Defines user roles in the system.

**Attributes:**
- `id` (UUID, Primary Key)
- `name` (String, Required, Unique) - "student", "owner", "admin"
- `createdAt` (Date)
- `updatedAt` (Date)

**Methods:**
- `findByName(name: string)` - Static method to find role by name
- `createRole(roleData)` - Static method to create new role

**Relationships:**
- Has many Users

### Hostel Model (`hostel-model.ts`)
Represents hostel properties.

**Attributes:**
- `id` (UUID, Primary Key)
- `hostelName` (String, Required)
- `phone` (String, Required)
- `address` (String, Required)
- `curfew` (Boolean, Default: false)
- `distance` (Float, Optional)
- `location` (String, Required)
- `rent` (Float, Required)
- `gender` (String, Required)
- `files` (String, Optional) - Image/document URLs
- `bedrooms` (Integer, Default: 1)
- `bathrooms` (Integer, Default: 1)
- `userId` (UUID, Foreign Key to User)
- `createdAt` (Date)
- `updatedAt` (Date)

**Methods:**
- `findById(id: string)` - Static method to find hostel by ID
- `createHostel(hostelData)` - Static method to create new hostel

**Relationships:**
- Belongs to User (owner)
- Has many Reviews
- Has one Amenities

### Student Model (`student-model.ts`)
Stores additional information for student users.

**Attributes:**
- `id` (UUID, Primary Key)
- `userName` (String, Required)
- `dob` (Date, Required)
- `country` (String, Required)
- `permanentAddress` (String, Required)
- `presentAddress` (String, Required)
- `city` (String, Required)
- `postalCode` (String, Required)
- `createdAt` (Date)
- `updatedAt` (Date)

**Methods:**
- `findById(id: string)` - Static method to find student by ID
- `createStudent(userData)` - Static method to create new student

**Relationships:**
- Belongs to User

### Owner Model (`owner-model.ts`)
Stores additional information for owner users.

**Attributes:**
- `id` (UUID, Primary Key)
- `name` (String, Required)
- `phone` (String, Required)
- `createdAt` (Date)
- `updatedAt` (Date)

**Methods:**
- `findById(id: string)` - Static method to find owner by ID
- `createOwner(ownerData)` - Static method to create new owner

**Relationships:**
- Belongs to User

### Review Model (`review-model.ts`)
Represents user reviews for hostels.

**Attributes:**
- `id` (UUID, Primary Key)
- `name` (String, Optional)
- `date` (Date, Required)
- `rating` (Integer, Required, 1-5)
- `text` (Text, Optional)
- `image` (String, Optional)
- `userId` (UUID, Foreign Key to User)
- `hostelId` (UUID, Foreign Key to Hostel)
- `createdAt` (Date)
- `updatedAt` (Date)

**Methods:**
- `findById(id: string)` - Static method to find review by ID
- `createReview(reviewData)` - Static method to create new review

**Relationships:**
- Belongs to User
- Belongs to Hostel

### Amenities Model (`ammenities-model.ts`)
Represents amenities available in hostels.

**Attributes:**
- `id` (UUID, Primary Key)
- `wifi` (Boolean, Required)
- `ac` (Boolean, Required)
- `kitchen` (Boolean, Required)
- `parking` (Boolean, Required)
- `laundry` (Boolean, Required)
- `tv` (Boolean, Required)
- `firstAid` (Boolean, Required)
- `workspace` (Boolean, Required)
- `security` (Boolean, Required)
- `currentBill` (Boolean, Required)
- `waterBill` (Boolean, Required)
- `food` (Boolean, Required)
- `furniture` (Boolean, Required)
- `bed` (Boolean, Required)
- `water` (Boolean, Required)
- `studentsCount` (Integer, Default: 0)
- `hostelId` (UUID, Foreign Key to Hostel)
- `createdAt` (Date)
- `updatedAt` (Date)

**Methods:**
- `findById(id: string)` - Static method to find amenities by ID
- `createAmmenities(amenitiesData)` - Static method to create new amenities

**Relationships:**
- Belongs to Hostel

## API Endpoints

### Authentication Routes (`/auth`)

#### POST `/auth/signup`
**Description**: Register a new user account
**Access**: Public
**Request Body**:
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "role": "student|owner|admin"
}
```
**Response**:
```json
{
  "success": true,
  "message": "User created successfully",
  "accessToken": "string",
  "refreshToken": "string"
}
```

#### POST `/auth/login`
**Description**: Login with email and password
**Access**: Public
**Request Body**:
```json
{
  "email": "string",
  "password": "string"
}
```
**Response**:
```json
{
  "success": true,
  "message": "Login successful",
  "accessToken": "string",
  "refreshToken": "string"
}
```

#### POST `/auth/token/refresh`
**Description**: Refresh access token using refresh token
**Access**: Public
**Request Body**:
```json
{
  "refreshToken": "string"
}
```
**Response**:
```json
{
  "success": true,
  "accessToken": "string",
  "refreshToken": "string"
}
```

#### GET `/auth/google`
**Description**: Initiate Google OAuth authentication
**Access**: Public
**Response**: Redirects to Google OAuth consent screen

#### GET `/auth/google/callback`
**Description**: Google OAuth callback handler
**Access**: Public (OAuth callback)
**Response**:
```json
{
  "success": true,
  "message": "Google authentication successful",
  "accessToken": "string",
  "refreshToken": "string"
}
```

### Hostel Routes (`/hostel`) - Protected

#### POST `/hostel`
**Description**: Create a new hostel
**Access**: Authenticated users only
**Request Body**:
```json
{
  "hostelName": "string",
  "phone": "string",
  "address": "string",
  "curfew": "boolean",
  "distance": "number",
  "location": "string",
  "rent": "number",
  "gender": "string",
  "files": "string (optional)",
  "bedrooms": "number",
  "bathrooms": "number"
}
```
**Response**:
```json
{
  "success": true,
  "message": "Hostel created successfully"
}
```

#### GET `/hostel`
**Description**: Get all hostels (for students)
**Access**: Authenticated users only
**Response**:
```json
[
  {
    "id": "uuid",
    "hostelName": "string",
    "phone": "string",
    "address": "string",
    "curfew": "boolean",
    "distance": "number",
    "location": "string",
    "rent": "number",
    "gender": "string",
    "files": "string",
    "bedrooms": "number",
    "bathrooms": "number",
    "createdAt": "date",
    "updatedAt": "date"
  }
]
```

#### GET `/hostel/user`
**Description**: Get all hostels owned by the authenticated user
**Access**: Authenticated users only
**Response**: Same as above but filtered by user

#### PUT `/hostel/:id`
**Description**: Update a specific hostel
**Access**: Authenticated users only (must be owner)
**Request Body**: Same as POST (partial updates allowed)
**Response**:
```json
{
  "message": "Hostel updated successfully"
}
```

#### DELETE `/hostel/:id`
**Description**: Delete a specific hostel
**Access**: Authenticated users only (must be owner)
**Response**: Status 204 No Content

### Review Routes (`/review`) - Protected

#### POST `/review`
**Description**: Create a new review for a hostel
**Access**: Authenticated users only
**Request Body**:
```json
{
  "hostelId": "uuid",
  "rating": "number (1-5)",
  "text": "string (optional)",
  "image": "string (optional)",
  "date": "date"
}
```
**Response**:
```json
{
  "ok": true,
  "message": "Review created successfully"
}
```

#### GET `/review/user`
**Description**: Get all reviews by the authenticated user
**Access**: Authenticated users only
**Response**:
```json
{
  "ok": true,
  "reviews": [
    {
      "id": "uuid",
      "name": "string",
      "date": "date",
      "rating": "number",
      "text": "string",
      "image": "string",
      "userId": "uuid",
      "hostelId": "uuid"
    }
  ]
}
```

#### GET `/review/review/hostel/:id`
**Description**: Get all reviews for a specific hostel
**Access**: Authenticated users only
**Response**: Same format as user reviews

#### GET `/review/:id`
**Description**: Get a specific review by ID
**Access**: Authenticated users only
**Response**:
```json
{
  "ok": true,
  "review": {
    "id": "uuid",
    "name": "string",
    "date": "date",
    "rating": "number",
    "text": "string",
    "image": "string",
    "userId": "uuid",
    "hostelId": "uuid"
  }
}
```

#### PUT `/review/:id`
**Description**: Update a specific review
**Access**: Authenticated users only (must be review author)
**Request Body**: Same as POST (partial updates allowed)
**Response**:
```json
{
  "ok": true,
  "message": "Review updated successfully"
}
```

#### DELETE `/review/:id`
**Description**: Delete a specific review
**Access**: Authenticated users only (must be review author)
**Response**:
```json
{
  "ok": true,
  "message": "Review deleted successfully"
}
```

### Amenities Routes (`/ammenities`) - Protected

#### POST `/ammenities`
**Description**: Create amenities for a hostel
**Access**: Authenticated users only
**Request Body**:
```json
{
  "hostelId": "uuid",
  "wifi": "boolean",
  "ac": "boolean",
  "kitchen": "boolean",
  "parking": "boolean",
  "laundry": "boolean",
  "tv": "boolean",
  "firstAid": "boolean",
  "workspace": "boolean",
  "security": "boolean",
  "currentBill": "boolean",
  "waterBill": "boolean",
  "food": "boolean",
  "furniture": "boolean",
  "bed": "boolean",
  "water": "boolean"
}
```
**Response**:
```json
{
  "ok": true,
  "message": "Amenities created successfully",
  "data": { ... }
}
```

#### GET `/ammenities/:id`
**Description**: Get amenities for a specific hostel
**Access**: Authenticated users only
**Response**:
```json
{
  "ok": true,
  "ammenities": {
    "id": "uuid",
    "wifi": "boolean",
    "ac": "boolean",
    // ... all amenity fields
    "hostelId": "uuid"
  }
}
```

#### PUT `/ammenities/:id`
**Description**: Update amenities for a hostel
**Access**: Authenticated users only
**Request Body**: Same as POST (partial updates allowed)
**Response**:
```json
{
  "ok": true,
  "message": "Ammenities updated successfully"
}
```

#### DELETE `/ammenities/:id`
**Description**: Delete amenities for a hostel
**Access**: Authenticated users only
**Response**:
```json
{
  "ok": true,
  "message": "Ammenities deleted successfully"
}
```

### Owner Routes (`/owner`) - Protected

#### POST `/owner/owners`
**Description**: Register a new owner
**Access**: Authenticated users only
**Request Body**:
```json
{
  "name": "string",
  "phone": "string"
}
```
**Response**: Returns created owner object

#### GET `/owner/owners`
**Description**: Get all owners
**Access**: Authenticated users only
**Response**: Array of owner objects

#### GET `/owner/owners/:id`
**Description**: Get a specific owner by ID
**Access**: Authenticated users only
**Response**: Owner object

#### PUT `/owner/owners/:id`
**Description**: Update a specific owner
**Access**: Authenticated users only
**Request Body**: Same as POST (partial updates allowed)
**Response**: Updated owner object

#### DELETE `/owner/owners/:id`
**Description**: Delete a specific owner
**Access**: Authenticated users only
**Response**: Status 204 No Content

### Documentation Routes

#### GET `/docs`
**Description**: API documentation interface (RapiDoc)
**Access**: Public
**Response**: HTML page with interactive API documentation

#### GET `/api-spec`
**Description**: OpenAPI specification JSON
**Access**: Public
**Response**: OpenAPI 3.0 JSON specification

### CAPTCHA Routes

#### POST `/captcha`
**Description**: Verify reCAPTCHA token
**Access**: Public
**Request Body**:
```json
{
  "g-recaptcha-response": "string"
}
```
**Response**:
```json
{
  "responseCode": 0,
  "responseDesc": "Captcha verification successful"
}
```

## Authentication & Authorization

### JWT Authentication
The application uses JSON Web Tokens (JWT) for authentication with two types of tokens:

1. **Access Token**: Short-lived (15 minutes), used for API requests
2. **Refresh Token**: Long-lived (7 days), used to generate new access tokens

### Google OAuth
Google OAuth 2.0 is implemented using Passport.js strategy:
- Scope: `profile` and `email`
- Callback URL: `/auth/google/callback`
- Session-based during OAuth flow
- JWT tokens issued upon successful authentication

### Authorization Middleware
The `authorize` middleware (`auth-middleware.ts`) protects routes by:
1. Extracting Bearer token from Authorization header
2. Verifying JWT signature
3. Finding user by email from token payload
4. Attaching user object to request

### Protected Routes
All routes except authentication and documentation routes require valid JWT tokens:
- `/hostel/*` - Protected
- `/review/*` - Protected  
- `/ammenities/*` - Protected
- `/owner/*` - Protected

## Middleware

### Request Logger (`request-logger.ts`)
Logs all incoming requests and outgoing responses with:
- HTTP method and URL
- Request IP and User-Agent
- Request body (for non-GET requests)
- Response status code and duration
- Response size

### Error Handling Middleware (`error-middleware.ts`)

#### Custom Error Classes
- **AppError**: Operational errors with status codes
- **ErrorHandler**: Generic error handler class

#### Error Types Handled
- Sequelize ValidationError (400)
- Sequelize UniqueConstraintError (400) 
- Sequelize DatabaseError (500)
- JWT errors (JsonWebTokenError, TokenExpiredError) (401)
- CastError (400)
- Custom AppError and ErrorHandler

#### Global Exception Handlers
- **Uncaught Exception**: Logs error and exits process
- **Unhandled Rejection**: Logs error and exits process

### Authentication Middleware (`auth-middleware.ts`)
Validates JWT tokens and attaches user to request object.

## Utilities & Configuration

### Logger (`logger.ts`)
Custom logging utility with:
- **Levels**: INFO, ERROR, WARN, SUCCESS
- **File Logging**: Separate files for different log types
- **Console Logging**: Colored output with emojis
- **Log Directory**: `./logs/`
- **Log Files**: `app.log`, `error.log`, `success.log`

### Response Handler (`response-handler.ts`)
Standardized response utility with:
- **Success responses**: Consistent success format
- **Error responses**: Consistent error format
- **Logging integration**: Automatic request/response logging

### Database Connection (`sequelize.ts`)
- **Database**: PostgreSQL
- **ORM**: Sequelize
- **Connection pooling**: Default Sequelize settings
- **Environment-based configuration**

### API Documentation (`docs.ts`, `api-spec.ts`)
- **Documentation UI**: RapiDoc (dark theme)
- **Specification**: OpenAPI 3.0 format
- **Interactive**: Allow testing directly from docs
- **Authentication**: Bearer token support in docs

### Database Seeding (`seed.ts`)
Comprehensive seeding utility with:
- **Roles**: student, owner, admin
- **Users**: 10 students, 5 owners with realistic data
- **Hostels**: 10-15 hostels with varied properties
- **Reviews**: 20-30 reviews with ratings 1-5
- **Amenities**: Random amenity combinations
- **Data Generation**: Faker.js for realistic test data

## Error Handling

### Error Response Format
```json
{
  "ok": false,
  "message": "Error description",
  "data": null
}
```

### Common HTTP Status Codes
- **200**: Success
- **201**: Created
- **204**: No Content (successful deletion)
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (authentication required)
- **403**: Forbidden (invalid token)
- **404**: Not Found
- **409**: Conflict (duplicate resource)
- **500**: Internal Server Error

### Validation
- **Zod schemas**: Input validation for all endpoints
- **Sequelize validation**: Database-level validation
- **Custom validation**: Business logic validation

## Database Configuration

### Environment Variables
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=pgbee_db
DB_USER=postgres
DB_PASSWORD=password
```

### Database Connection
- **Dialect**: PostgreSQL
- **Host**: Configurable via environment
- **Port**: Default 5432
- **Connection testing**: Automatic on startup
- **Error handling**: Graceful connection failure handling

### Migrations
Sequelize CLI migrations for database schema:
- `20250722062547-create-user-table.cjs`
- `20250722090230-create-owner-table.cjs`  
- `20250722100832-create-roles-table.cjs`
- `20250722101429-create-students-table.cjs`

### Model Relationships
```
User (1) -> (1) Role
User (1) -> (0..1) Owner
User (1) -> (0..1) Student  
User (1) -> (*) Hostel
User (1) -> (*) Review

Hostel (1) -> (*) Review
Hostel (1) -> (1) Amenities
```

## Development Setup

### Prerequisites
- Node.js (v18+)
- PostgreSQL (v12+)
- pnpm package manager

### Environment Setup
1. Clone repository
2. Install dependencies: `pnpm install`
3. Create `.env` file with required variables
4. Setup PostgreSQL database
5. Run migrations: `pnpm run db:migrate`
6. Start development server: `pnpm run dev`

### Available Scripts
```json
{
  "dev": "nodemon --exec tsx src/index.ts",
  "build": "tsc",
  "start": "node dist/index.js",
  "lint": "eslint",
  "lint:fix": "eslint --fix",
  "prepare": "husky",
  "db:create": "npx sequelize-cli db:create",
  "db:migrate": "npx sequelize-cli db:migrate",
  "migrate:undo": "npx sequelize-cli db:migrate:undo",
  "migrate:undo:all": "npx sequelize-cli db:migrate:undo:all",
  "migration:generate": "npx sequelize-cli migration:generate --name"
}
```

### Development Tools
- **TypeScript**: Static typing and modern JavaScript features
- **Nodemon**: Auto-restart on file changes
- **TSX**: TypeScript execution without compilation
- **ESLint**: Code linting with TypeScript support
- **Prettier**: Code formatting
- **Husky**: Git hooks for pre-commit validation
- **lint-staged**: Run linters on staged files only

## Docker Configuration

### Dockerfile
Multi-stage Node.js Docker build optimized for production deployment.

### Docker Compose
Includes:
- Web service (Node.js application)
- Database service (PostgreSQL)
- Nginx reverse proxy
- SSL/TLS configuration with Let's Encrypt

### Production Deployment
- **SSL**: Let's Encrypt certificates
- **Reverse Proxy**: Nginx configuration
- **Environment**: Production-optimized settings
- **Health Checks**: Container health monitoring
- **Logging**: Centralized logging configuration

### Environment Variables for Production
```env
NODE_ENV=production
PORT=3000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=pgbee_production
DB_USER=pgbee_user
DB_PASSWORD=secure_password
JWT_SECRET=your_jwt_secret_key
REFRESH_TOKEN=your_refresh_token_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
SESSION_SECRET=your_session_secret
RECAPTCHA_SECRET_KEY=your_recaptcha_secret
```

---

## API Usage Examples

### Authentication Flow
```bash
# 1. Register new user
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "student"
  }'

# 2. Login
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'

# 3. Use access token for protected routes
curl -X GET http://localhost:3000/hostel \
  -H "Authorization: Bearer your_access_token"
```

### Creating a Hostel
```bash
curl -X POST http://localhost:3000/hostel \
  -H "Authorization: Bearer your_access_token" \
  -H "Content-Type: application/json" \
  -d '{
    "hostelName": "Sunrise Hostel",
    "phone": "+1234567890",
    "address": "123 Main St, City",
    "curfew": false,
    "distance": 2.5,
    "location": "Downtown",
    "rent": 5000,
    "gender": "mixed",
    "bedrooms": 2,
    "bathrooms": 1
  }'
```

This documentation provides a comprehensive overview of the PGBee server codebase, covering all aspects from architecture to deployment. The API follows RESTful conventions and implements robust authentication, validation, and error handling patterns.
