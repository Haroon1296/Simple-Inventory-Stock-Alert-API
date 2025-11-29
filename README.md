# Inventory & Stock Alert API

A simple, RESTful API for managing inventory and tracking stock levels with automatic alerts using Node.js, Express, and Supabase.

## Features

- **Product Management**: Create, read, update, and delete products
- **Stock Tracking**: Monitor product quantities in real-time
- **Automatic Alerts**: Get notified when stock falls below minimum levels or runs out
- **Low Stock Detection**: Identify products that need restocking
- **Alert Management**: Resolve and track stock alerts

## Prerequisites

- Node.js (v14 or higher)
- npm
- Supabase account with a project

## Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
Create a `.env` file in the root directory:
```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
PORT=3000
```

Get your Supabase credentials from the Supabase dashboard:
- Go to Settings > API
- Copy your project URL and anon public key

## Getting Started

1. Start the server:
```bash
npm start
```

2. The API will be available at `http://localhost:3000`

3. Check the status:
```bash
curl http://localhost:3000
```

## API Documentation

### Base URL
```
http://localhost:3000/api
```

### Products Endpoints

#### Get All Products
```
GET /products
```
Response:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Product Name",
      "sku": "SKU123",
      "quantity": 50,
      "min_stock_level": 10,
      "price": 29.99,
      "category": "Electronics",
      "created_at": "2024-11-29T12:00:00Z"
    }
  ]
}
```

#### Get Product by ID
```
GET /products/:id
```

#### Get Low Stock Products
```
GET /products/low-stock
```
Returns products where quantity is at or below the minimum stock level.

#### Create Product
```
POST /products
Content-Type: application/json

{
  "name": "Product Name",
  "sku": "SKU123",
  "description": "Product description",
  "quantity": 100,
  "min_stock_level": 10,
  "price": 29.99,
  "category": "Electronics"
}
```

#### Update Product
```
PUT /products/:id
Content-Type: application/json

{
  "name": "Updated Name",
  "price": 39.99
}
```

#### Update Stock Quantity
```
PATCH /products/:id/stock
Content-Type: application/json

{
  "quantity": 75
}
```

#### Delete Product
```
DELETE /products/:id
```

### Stock Alerts Endpoints

#### Get All Alerts
```
GET /alerts
```

#### Get Unresolved Alerts
```
GET /alerts/unresolved
```
Returns only alerts that haven't been marked as resolved.

#### Get Alerts for Specific Product
```
GET /alerts/product/:productId
```

#### Resolve Alert
```
PATCH /alerts/:id/resolve
```
Marks an alert as resolved with a timestamp.

#### Delete Alert
```
DELETE /alerts/:id
```

## Database Schema

### Products Table
- `id` (uuid) - Primary key
- `name` (text) - Product name
- `sku` (text) - Stock Keeping Unit (unique)
- `description` (text) - Product description
- `quantity` (integer) - Current stock quantity
- `min_stock_level` (integer) - Minimum threshold for alerts
- `price` (decimal) - Product price
- `category` (text) - Product category
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update timestamp

### Stock Alerts Table
- `id` (uuid) - Primary key
- `product_id` (uuid) - Reference to product
- `alert_type` (text) - 'low_stock' or 'out_of_stock'
- `message` (text) - Alert message
- `is_resolved` (boolean) - Resolution status
- `created_at` (timestamptz) - Alert creation timestamp
- `resolved_at` (timestamptz) - Resolution timestamp

## Automatic Features

- **Updated At**: The `updated_at` field is automatically updated whenever a product is modified
- **Stock Alerts**: Alerts are automatically created when:
  - Stock quantity becomes 0 (out of stock alert)
  - Stock quantity falls to or below the minimum stock level (low stock alert)

## Example Usage

### Create a Product
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "sku": "LAPTOP001",
    "description": "High-performance laptop",
    "quantity": 5,
    "min_stock_level": 10,
    "price": 999.99,
    "category": "Electronics"
  }'
```

### Update Stock
```bash
curl -X PATCH http://localhost:3000/api/products/{product-id}/stock \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 2
  }'
```

### Get Unresolved Alerts
```bash
curl http://localhost:3000/api/alerts/unresolved
```

## Error Handling

The API returns error responses with appropriate HTTP status codes:

```json
{
  "success": false,
  "error": "Error message description"
}
```

Common status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `404` - Not Found
- `500` - Internal Server Error

## Development

### Available Scripts

- `npm start` - Start the server
- `npm run dev` - Start the server (same as start)
- `npm run build` - Verify build

## Project Structure

```
project/
├── src/
│   ├── config/
│   │   └── supabase.js          # Supabase client setup
│   ├── controllers/
│   │   ├── productController.js # Product business logic
│   │   └── alertController.js   # Alert business logic
│   ├── middleware/
│   │   └── errorHandler.js      # Error handling middleware
│   ├── routes/
│   │   ├── productRoutes.js     # Product API routes
│   │   └── alertRoutes.js       # Alert API routes
│   └── server.js                # Express app setup
├── .env                         # Environment variables
├── .env.example                 # Example environment file
├── package.json                 # Dependencies
└── README.md                    # This file
```

## Security Notes

- Ensure your `.env` file is never committed to version control
- Always use environment variables for sensitive data
- The API implements Row Level Security (RLS) at the database level
- Validate and sanitize all inputs

## Troubleshooting

### Connection Error to Supabase
- Verify your `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in `.env`
- Ensure your Supabase project is active
- Check your internet connection

### Port Already in Use
- Change the `PORT` variable in `.env`
- Or kill the process using port 3000

### Migrations Not Applied
- Ensure your `.env` is correctly configured
- The migrations should be automatically applied via the Supabase dashboard

## License

MIT

## Support

For issues or questions, please check the project structure and ensure all environment variables are correctly set.
