
# URL Documentation

This document provides a detailed overview of the URL patterns and their corresponding views.

---

## Authentication Routes (`/auth`)

- **POST `/login`**: User login.
- **POST `/signup`**: User signup.
- **POST `/token/refresh`**: Refresh authentication token.
- **GET `/google`**: Initiate Google login.
- **GET `/google/callback`**: Callback for Google login.
- **GET `/test`**: A test route that requires authorization.

---

## Owner Routes (`/owners`)

- **POST `/owners`**: Register a new owner.
- **GET `/owners`**: Get a list of all owners.
- **GET `/owners/:id`**: Get an owner by their ID.
- **PUT `/owners/:id`**: Update an owner's information.
- **DELETE `/owners/:id`**: Delete an owner.
