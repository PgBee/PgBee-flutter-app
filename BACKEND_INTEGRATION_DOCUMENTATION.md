# PgBee Flutter App - Backend Integration Documentation

## Overview
This document provides comprehensive information about the PgBee Flutter application's backend integration requirements. It includes all API endpoints, data models, authentication flow, and implementation details that the backend team needs to implement.

## Base Configuration
- **Backend Server URL**: `https://server.pgbee.in`
- **Authentication**: JWT (JSON Web Tokens) with Bearer token authentication
- **API Response Format**: JSON
- **HTTP Methods**: GET, POST, PUT, DELETE
- **Content-Type**: `application/json`

## Authentication System

### JWT Token Structure
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "role": "owner|student",
    "createdAt": "ISO 8601 date",
    "updatedAt": "ISO 8601 date"
  }
}
```

### Headers for Authenticated Requests
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

## API Endpoints

### 1. Authentication Endpoints (`/auth/*`)

#### POST `/auth/login`
**Purpose**: User login with email and password
**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
**Success Response** (200):
```json
{
  "success": true,
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "user": {
    "id": "user_uuid",
    "name": "John Doe",
    "email": "user@example.com",
    "role": "owner",
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  }
}
```
**Error Response** (401):
```json
{
  "success": false,
  "error": "Invalid credentials"
}
```

#### POST `/auth/signup`
**Purpose**: User registration
**Request Body**:
```json
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password123",
  "role": "owner",
  "phone": "+91 9876543210"
}
```
**Success Response** (201):
```json
{
  "success": true,
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "user": {
    "id": "user_uuid",
    "name": "John Doe",
    "email": "user@example.com",
    "role": "owner",
    "phone": "+91 9876543210",
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  }
}
```

#### POST `/auth/google`
**Purpose**: Initiate Google OAuth signin
**Request Body**:
```json
{
  "token": "google_oauth_token"
}
```
**Success Response** (200):
```json
{
  "success": true,
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "user": {
    "id": "user_uuid",
    "name": "John Doe",
    "email": "user@gmail.com",
    "role": "student",
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  }
}
```

#### POST `/auth/google/callback`
**Purpose**: Handle Google OAuth callback
**Request Body**:
```json
{
  "code": "google_auth_code"
}
```

#### POST `/auth/refresh`
**Purpose**: Refresh access token using refresh token
**Request Body**:
```json
{
  "refreshToken": "jwt_refresh_token"
}
```
**Success Response** (200):
```json
{
  "success": true,
  "accessToken": "new_jwt_access_token",
  "refreshToken": "new_jwt_refresh_token"
}
```

#### GET `/auth/test`
**Purpose**: Test route for authentication validation
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "message": "Authentication successful",
  "user": {
    "id": "user_uuid",
    "email": "user@example.com",
    "role": "owner"
  }
}
```

### 2. Hostel Management Endpoints (`/hostel/*`)

#### POST `/hostel`
**Purpose**: Create a new hostel (Owner only)
**Headers**: `Authorization: Bearer {accessToken}`
**Request Body**:
```json
{
  "name": "PG Bee Hostel",
  "ownerName": "John Doe",
  "phone": "+91 9876543210",
  "address": "123 Main Street, City",
  "location": "Near University",
  "description": "A comfortable hostel for students",
  "rent": 8000.0,
  "distance": 2.5,
  "bedrooms": 2,
  "bathrooms": 2,
  "curfew": false,
  "files": ["image1.jpg", "image2.jpg"],
  "amenities": [
    {
      "id": "amenity_uuid",
      "name": "WiFi",
      "description": "High-speed internet",
      "isAvailable": true
    }
  ]
}
```
**Success Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "hostel_uuid",
    "name": "PG Bee Hostel",
    "ownerName": "John Doe",
    "phone": "+91 9876543210",
    "address": "123 Main Street, City",
    "location": "Near University",
    "description": "A comfortable hostel for students",
    "rent": 8000.0,
    "distance": 2.5,
    "bedrooms": 2,
    "bathrooms": 2,
    "curfew": false,
    "files": ["image1.jpg", "image2.jpg"],
    "amenities": [...],
    "admittedStudents": 0,
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  }
}
```

#### GET `/hostel/user`
**Purpose**: Get hostels for the authenticated owner
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "hostel_uuid",
      "name": "PG Bee Hostel",
      "ownerName": "John Doe",
      "phone": "+91 9876543210",
      "address": "123 Main Street, City",
      "location": "Near University",
      "description": "A comfortable hostel for students",
      "rent": 8000.0,
      "distance": 2.5,
      "bedrooms": 2,
      "bathrooms": 2,
      "curfew": false,
      "files": ["image1.jpg", "image2.jpg"],
      "amenities": [...],
      "admittedStudents": 15,
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z"
    }
  ]
}
```

#### PUT `/hostel/:id`
**Purpose**: Update hostel details (Owner only)
**Headers**: `Authorization: Bearer {accessToken}`
**Request Body**: Same as POST `/hostel`
**Success Response** (200):
```json
{
  "success": true,
  "data": {
    // Updated hostel object
  }
}
```

#### DELETE `/hostel/:id`
**Purpose**: Delete a hostel (Owner only)
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "message": "Hostel deleted successfully"
}
```

#### GET `/hostel/search`
**Purpose**: Search hostels for students
**Query Parameters**:
- `location` (string, optional)
- `minRent` (number, optional)
- `maxRent` (number, optional)
- `amenities` (array, optional)
**Success Response** (200):
```json
{
  "success": true,
  "data": [
    // Array of hostel objects matching search criteria
  ]
}
```

### 3. Enquiry Management Endpoints (`/enquiries/*`)

#### POST `/enquiries`
**Purpose**: Create a new enquiry (Students)
**Request Body**:
```json
{
  "studentName": "Alice Johnson",
  "studentEmail": "alice@email.com",
  "studentPhone": "+91 9876543210",
  "hostelId": "hostel_uuid",
  "message": "I am interested in booking a room",
  "status": "pending"
}
```
**Success Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "enquiry_uuid",
    "studentName": "Alice Johnson",
    "studentEmail": "alice@email.com",
    "studentPhone": "+91 9876543210",
    "hostelId": "hostel_uuid",
    "hostelName": "PG Bee Hostel",
    "message": "I am interested in booking a room",
    "status": "pending",
    "createdAt": "2025-01-01T00:00:00Z",
    "respondedAt": null
  }
}
```

#### GET `/enquiries`
**Purpose**: Get all enquiries for the authenticated owner
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "enquiry_uuid",
      "studentName": "Alice Johnson",
      "studentEmail": "alice@email.com",
      "studentPhone": "+91 9876543210",
      "hostelId": "hostel_uuid",
      "hostelName": "PG Bee Hostel",
      "message": "I am interested in booking a room",
      "status": "pending",
      "createdAt": "2025-01-01T00:00:00Z",
      "respondedAt": null
    }
  ]
}
```

#### GET `/enquiries/hostel/:id`
**Purpose**: Get enquiries for a specific hostel
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "data": [
    // Array of enquiry objects for the specified hostel
  ]
}
```

#### PUT `/enquiries/:id`
**Purpose**: Update enquiry status (Accept/Deny)
**Headers**: `Authorization: Bearer {accessToken}`
**Request Body**:
```json
{
  "status": "accepted" // or "denied"
}
```
**Success Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "enquiry_uuid",
    "status": "accepted",
    "respondedAt": "2025-01-01T00:00:00Z"
  }
}
```

#### DELETE `/enquiries/:id`
**Purpose**: Delete an enquiry
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "message": "Enquiry deleted successfully"
}
```

#### GET `/enquiries/stats`
**Purpose**: Get enquiry statistics for dashboard
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "data": {
    "total": 25,
    "pending": 8,
    "accepted": 12,
    "denied": 5
  }
}
```

### 4. Amenities Management Endpoints (`/amenities/*`)

#### GET `/amenities`
**Purpose**: Get all available amenities
**Success Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "amenity_uuid",
      "name": "WiFi",
      "description": "High-speed internet connection",
      "category": "connectivity",
      "isActive": true
    }
  ]
}
```

#### POST `/amenities`
**Purpose**: Create a new amenity (Admin only)
**Headers**: `Authorization: Bearer {accessToken}`
**Request Body**:
```json
{
  "name": "Swimming Pool",
  "description": "Outdoor swimming pool",
  "category": "recreation"
}
```

#### PUT `/amenities/:id`
**Purpose**: Update amenity details
**Headers**: `Authorization: Bearer {accessToken}`
**Request Body**:
```json
{
  "name": "Updated WiFi",
  "description": "High-speed fiber internet",
  "category": "connectivity",
  "isActive": true
}
```

#### DELETE `/amenities/:id`
**Purpose**: Delete an amenity
**Headers**: `Authorization: Bearer {accessToken}`

### 5. Owner Profile Endpoints (`/owner/*`)

#### GET `/owner/profile`
**Purpose**: Get owner profile details
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "owner_uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+91 9876543210",
    "address": "123 Main Street",
    "totalHostels": 2,
    "totalStudents": 30,
    "totalEnquiries": 15,
    "joinedAt": "2025-01-01T00:00:00Z"
  }
}
```

#### PUT `/owner/profile`
**Purpose**: Update owner profile
**Headers**: `Authorization: Bearer {accessToken}`
**Request Body**:
```json
{
  "name": "John Doe Updated",
  "phone": "+91 9876543211",
  "address": "456 New Street"
}
```

#### GET `/owner/dashboard`
**Purpose**: Get dashboard statistics for owner
**Headers**: `Authorization: Bearer {accessToken}`
**Success Response** (200):
```json
{
  "success": true,
  "data": {
    "totalHostels": 2,
    "totalStudents": 30,
    "pendingEnquiries": 5,
    "monthlyRevenue": 240000,
    "recentEnquiries": [
      // Array of recent enquiry objects
    ],
    "occupancyRate": 85.5
  }
}
```

### 6. Review Management Endpoints (`/reviews/*`)

#### POST `/reviews`
**Purpose**: Create a new review (Students only)
**Headers**: `Authorization: Bearer {accessToken}`
**Request Body**:
```json
{
  "hostelId": "hostel_uuid",
  "rating": 4.5,
  "comment": "Great place to stay with excellent amenities",
  "categories": {
    "cleanliness": 5,
    "food": 4,
    "safety": 5,
    "staff": 4
  }
}
```

#### GET `/reviews/hostel/:id`
**Purpose**: Get all reviews for a hostel
**Success Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "review_uuid",
      "studentName": "Alice Johnson",
      "hostelId": "hostel_uuid",
      "rating": 4.5,
      "comment": "Great place to stay",
      "categories": {
        "cleanliness": 5,
        "food": 4,
        "safety": 5,
        "staff": 4
      },
      "createdAt": "2025-01-01T00:00:00Z"
    }
  ]
}
```

#### GET `/reviews/stats/:hostelId`
**Purpose**: Get review statistics for a hostel
**Success Response** (200):
```json
{
  "success": true,
  "data": {
    "averageRating": 4.3,
    "totalReviews": 25,
    "ratingDistribution": {
      "5": 10,
      "4": 8,
      "3": 5,
      "2": 1,
      "1": 1
    }
  }
}
```

## Data Models

### User Model
```json
{
  "id": "uuid",
  "name": "string",
  "email": "string (unique)",
  "password": "string (hashed)",
  "role": "owner|student|admin",
  "phone": "string",
  "address": "string",
  "isVerified": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Hostel Model
```json
{
  "id": "uuid",
  "ownerId": "uuid (foreign key)",
  "name": "string",
  "ownerName": "string",
  "phone": "string",
  "address": "string",
  "location": "string",
  "description": "text",
  "rent": "decimal",
  "distance": "decimal",
  "bedrooms": "integer",
  "bathrooms": "integer",
  "curfew": "boolean",
  "files": "array of strings",
  "amenities": "array of amenity objects",
  "admittedStudents": "integer",
  "maxCapacity": "integer",
  "isActive": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Enquiry Model
```json
{
  "id": "uuid",
  "studentId": "uuid (foreign key, optional)",
  "studentName": "string",
  "studentEmail": "string",
  "studentPhone": "string",
  "hostelId": "uuid (foreign key)",
  "hostelName": "string",
  "message": "text",
  "status": "pending|accepted|denied",
  "createdAt": "datetime",
  "respondedAt": "datetime (nullable)"
}
```

### Amenity Model
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "category": "string",
  "icon": "string (optional)",
  "isActive": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Review Model
```json
{
  "id": "uuid",
  "studentId": "uuid (foreign key)",
  "studentName": "string",
  "hostelId": "uuid (foreign key)",
  "rating": "decimal (1-5)",
  "comment": "text",
  "categories": "json object",
  "isVerified": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

## Error Handling

### Standard Error Response Format
```json
{
  "success": false,
  "error": "Error message description",
  "code": "ERROR_CODE", // Optional
  "details": {} // Optional additional details
}
```

### Common HTTP Status Codes
- **200**: Success
- **201**: Created
- **400**: Bad Request
- **401**: Unauthorized
- **403**: Forbidden
- **404**: Not Found
- **422**: Validation Error
- **500**: Internal Server Error

### Validation Error Response
```json
{
  "success": false,
  "error": "Validation failed",
  "details": {
    "email": ["Email is required", "Email format is invalid"],
    "password": ["Password must be at least 8 characters"]
  }
}
```

## Security Requirements

### Authentication
- JWT tokens with expiration
- Refresh token rotation
- Secure password hashing (bcrypt)
- Rate limiting on authentication endpoints

### Authorization
- Role-based access control
- Owner can only access their own hostels and enquiries
- Students can create enquiries and reviews
- Admin can manage amenities and system settings

### Data Protection
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- CORS configuration
- HTTPS enforcement

## Database Considerations

### Indexes
- User email (unique index)
- Hostel owner_id
- Enquiry hostel_id and status
- Review hostel_id
- Timestamps for sorting

### Relationships
- User has many Hostels (owner relationship)
- Hostel has many Enquiries
- Hostel has many Reviews
- User has many Reviews (student relationship)
- Hostel has many Amenities (many-to-many)

## File Upload Requirements

### Image Upload Endpoints
- `POST /upload/hostel-images`
- `POST /upload/profile-image`

### File Specifications
- Supported formats: JPEG, PNG, WebP
- Maximum file size: 5MB per image
- Maximum files per upload: 10
- Image processing: Auto-resize to multiple sizes

### Storage
- Cloud storage (AWS S3, Google Cloud Storage, etc.)
- CDN for fast image delivery
- Automatic image optimization

## Real-time Features (Optional)

### WebSocket Events
- New enquiry notifications for owners
- Enquiry status updates for students
- Real-time dashboard updates

## Performance Requirements

### Response Times
- Authentication: < 500ms
- Data retrieval: < 1000ms
- File uploads: < 5000ms

### Scalability
- Support for 10,000+ hostels
- Support for 100,000+ enquiries
- Efficient pagination for large datasets

## Testing Requirements

### Unit Tests
- All API endpoints
- Authentication middleware
- Validation logic
- Business logic

### Integration Tests
- End-to-end API workflows
- Database operations
- File upload processes

### Performance Tests
- Load testing for high traffic
- Database query optimization
- Memory usage monitoring

## Deployment Notes

### Environment Variables
```env
DATABASE_URL=postgresql://user:password@host:port/database
JWT_SECRET=your-secret-key
JWT_REFRESH_SECRET=your-refresh-secret
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
S3_BUCKET_NAME=your-bucket-name
```

### Production Checklist
- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] SSL certificates installed
- [ ] Monitoring and logging setup
- [ ] Backup strategy implemented
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] CORS properly configured

## Contact Information

For technical questions or clarifications about this API specification, please contact the Flutter development team.

---

**Last Updated**: July 30, 2025
**API Version**: 1.0
**Documentation Version**: 1.0
