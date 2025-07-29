
# PGBee Server Documentation

This document provides a comprehensive overview of the PGBee server application, including its structure, setup instructions, API endpoints, and database models.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Environment Variables](#environment-variables)
  - [Running the Application](#running-the-application)
- [API Endpoints](#api-endpoints)
  - [Authentication](#authentication)
  - [Hostels](#hostels)
  - [Owners](#owners)
  - [Reviews](#reviews)
  - [Amenities](#amenities)
- [Database Schema](#database-schema)
  - [User Model](#user-model)
  - [Hostel Model](#hostel-model)
  - [Owner Model](#owner-model)
  - [Review Model](#review-model)
  - [Amenity Model](#amenity-model)
  - [Role Model](#role-model)
  - [Student Model](#student-model)
- [Middleware](#middleware)
  - [Authentication Middleware](#authentication-middleware)
- [Deployment](#deployment)

---

## Project Overview

The PGBee server is a robust backend solution for a hostel management application. It provides a comprehensive set of features for managing hostels, owners, user authentication, and reviews. The application is built with Node.js, Express, and Sequelize, and it uses a PostgreSQL database.

---

## Project Structure

The project is organized into the following directories:

- **db/**: Contains database-related files, including migrations and configuration.
- **src/**: The main source code directory.
  - **config/**: Configuration files for services like Passport.
  - **controllers/**: Request handlers for API endpoints.
  - **middlewares/**: Custom middleware for authentication and other tasks.
  - **models/**: Sequelize models for database tables.
  - **routes/**: API route definitions.
  - **types/**: TypeScript type definitions.
  - **utils/**: Utility functions and helper modules.
- **views/**: EJS templates for rendering pages.

---

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- npm or pnpm
- PostgreSQL

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kaali18/pgbee-server.git
   cd pgbee-server
   ```

2. **Install dependencies:**
   ```bash
   pnpm install
   ```

### Environment Variables

Create a `.env` file in the root directory and add the following environment variables:

```env
DB_USER=your_db_user
DB_PASS=your_db_password
DB_NAME=your_db_name
DB_HOST=localhost
DB_PORT=5432
JWT_SECRET=your_jwt_secret
```

### Running the Application

1. **Run database migrations:**
   ```bash
   pnpm db:migrate
   ```

2. **Start the development server:**
   ```bash
   pnpm dev
   ```

The server will be running at `http://localhost:3000`.

---

## API Endpoints

### Authentication

- **`POST /login`**: User login.
- **`POST /signup`**: User registration.
- **`POST /token/refresh`**: Refresh authentication token.
- **`GET /google`**: Initiate Google OAuth login.
- **`GET /google/callback`**: Google OAuth callback URL.

### Hostels

- **`GET /`**: Get all hostels for students.
- **`GET /user`**: Get all hostels for the owner.
- **`POST /hostel`**: Register a new hostel.
- **`PUT /hostel/:id`**: Update a hostel.
- **`DELETE /hostel/:id`**: Delete a hostel.

### Owners

- **`POST /owners`**: Register a new owner.
- **`GET /owners`**: Get all owners.
- **`GET /owners/:id`**: Get an owner by ID.
- **`PUT /owners/:id`**: Update an owner.
- **`DELETE /owners/:id`**: Delete an owner.

### Reviews

- **`POST /create`**: Create a new review.
- **`GET /review/user`**: Get all reviews for the user.
- **`GET /review/hostel/:id`**: Get all reviews for a hostel.
- **`GET /review/:id`**: Get a review by ID.
- **`PUT /review/:id`**: Update a review.
- **`DELETE /review/:id`**: Delete a review.

### Amenities

- **`POST /amenities/create`**: Create new amenities.
- **`PUT /amenities/update/:id`**: Update amenities.
- **`GET /amenities/hostel/:id`**: Get amenities for a hostel.

---

## Database Schema

### User Model

- `id`: UUID (Primary Key)
- `username`: String
- `email`: String (Unique)
- `password`: String
- `roleId`: UUID (Foreign Key to `Role`)

### Hostel Model

- `id`: UUID (Primary Key)
- `name`: String
- `address`: String
- `ownerId`: UUID (Foreign Key to `Owner`)

### Owner Model

- `id`: UUID (Primary Key)
- `name`: String
- `contact`: String

### Review Model

- `id`: UUID (Primary Key)
- `rating`: Integer
- `comment`: String
- `userId`: UUID (Foreign Key to `User`)
- `hostelId`: UUID (Foreign Key to `Hostel`)

### Amenity Model

- `id`: UUID (Primary Key)
- `name`: String
- `description`: String

### Role Model

- `id`: UUID (Primary Key)
- `name`: String (e.g., "student", "owner")

### Student Model

- `id`: UUID (Primary Key)
- `name`: String
- `userId`: UUID (Foreign Key to `User`)

---

## Middleware

### Authentication Middleware

The `authorize` middleware is used to protect routes that require authentication. It verifies the JWT token from the request headers and attaches the user object to the request.

---

## Deployment

The application is configured for deployment with Docker and Nginx. The `docker-compose.yaml` file defines the services for the application, database, and reverse proxy. The `init-letsencrypt.sh` script can be used to set up SSL with Let's Encrypt.
