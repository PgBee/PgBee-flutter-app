
# Model Documentation

This document provides a detailed overview of the database models used in this project.

---

## Owner Model

Represents an owner of a hostel.

### Fields

- `id`: UUID (Primary Key) - Unique identifier for the owner.
- `name`: STRING - Name of the owner.
- `hostelName`: STRING - Name of the hostel.
- `phone`: STRING - Contact number of the owner.
- `address`: STRING - Address of the hostel.
- `curfew`: BOOLEAN - Whether the hostel has a curfew (default: `false`).
- `description`: STRING - Description of the hostel.
- `distance`: FLOAT - Distance of the hostel from a reference point.
- `location`: STRING - Location of the hostel.
- `rent`: FLOAT - Rent of the hostel.
- `files`: STRING - Files associated with the hostel.
- `bedrooms`: INTEGER - Number of bedrooms in the hostel (default: 1).
- `bathrooms`: INTEGER - Number of bathrooms in the hostel (default: 1).
- `createdAt`: DATE - Timestamp of creation.
- `updatedAt`: DATE - Timestamp of last update.

### Methods

- `findById(id)`: Finds an owner by their ID.
- `createOwner(ownerData)`: Creates a new owner.

---

## Role Model

Represents a user role (e.g., admin, user).

### Fields

- `id`: UUID (Primary Key) - Unique identifier for the role.
- `name`: STRING (Unique) - Name of the role.
- `createdAt`: DATE - Timestamp of creation.
- `updatedAt`: DATE - Timestamp of last update.

### Methods

- `findByName(name)`: Finds a role by its name.
- `createRole(roleData)`: Creates a new role.

---

## Student Model

Represents a student user.

### Fields

- `id`: UUID (Primary Key) - Unique identifier for the student.
- `email`: STRING - Email of the student.
- `createdAt`: DATE - Timestamp of creation.
- `updatedAt`: DATE - Timestamp of last update.

### Methods

- `findByEmail(email)`: Finds a student by their email.
- `createStudent(userData)`: Creates a new student.

---

## User Model

Represents a general user.

### Fields

- `id`: UUID (Primary Key) - Unique identifier for the user.
- `email`: STRING (Unique) - Email of the user.
- `password`: STRING - Hashed password of the user.
- `role`: STRING - Role of the user.
- `createdAt`: DATE - Timestamp of creation.
- `updatedAt`: DATE - Timestamp of last update.

### Methods

- `verifyPassword(password)`: Verifies the user's password.
- `findByEmail(email)`: Finds a user by their email.
- `createUser(userData)`: Creates a new user.
- `setRole(role)`: Sets the role for the user.
- `getRole()`: Gets the role of the user.

---

## Relationships

- **Role-User**: One-to-One (A role can have one user, and a user belongs to one role).
- **User-Owner**: One-to-One (A user can have one owner profile).
- **User-Student**: One-to-One (A user can have one student profile).
