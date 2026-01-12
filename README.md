# virtual_try_web

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# API Documentation

The application consumes the following APIs:

## Base URLs
- **Main Backend:** `http://localhost:5000/api`
- **Try-On Service:** `http://localhost:8000`

## Endpoints

### Authentication (`/auth`)
- `POST /login` - User login
- `POST /register` - User registration
- `PUT /profile` - Update user profile
- `POST /upload-profile` - Upload profile picture

### Products (`/products`)
- `GET /` - Fetch all products
- `GET /myproducts` - Fetch products for the logged-in brand
- `POST /` - Create a new product
- `PUT /:id` - Update a product
- `DELETE /:id` - Delete a product

### Orders (`/orders`)
- `GET /` - Fetch all orders (Admin)
- `GET /myorders` - Fetch user's orders
- `POST /` - Place a new order
- `PUT /:id/status` - Update order status (Admin)
- `DELETE /:id` - Delete an order

### Payment (`/payment`)
- `POST /create-payment-intent` - Initialize Stripe payment
- `POST /confirm-payment` - Confirm payment success

### Analytics & Activities (`/analytics`, `/activities`)
- `GET /analytics` - Get dashboard analytics
- `POST /analytics/try-on` - Log try-on usage
- `GET /activities` - Get admin activity log
- `POST /activities` - Log a new activity

### Virtual Try-On (`/try-on`)
- `POST /try-on` - Process virtual try-on request (Requires `person_image` and `cloth_image`)
