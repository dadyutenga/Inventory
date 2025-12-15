# Public Products API Documentation

## Overview

The Public Products API provides read-only access to all available products in the inventory system. This API is designed for public consumption and does not require authentication. It includes comprehensive security measures, rate limiting, and caching for optimal performance.

## Base URL

```
/api/v1/
```

## Authentication

No authentication required. This is a public API.

## Rate Limiting

- **Limit**: 100 requests per minute per IP address
- **Window**: 60 seconds
- **Response**: When exceeded, returns HTTP 429 with retry-after header

### Rate Limit Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640123400
```

## Caching

- **Cache Duration**: 5 minutes
- **Cache Strategy**: In-memory caching with automatic invalidation
- **Cache Keys**: Based on product type and query parameters
- **Invalidation**: Automatic when products are created, updated, or deleted

## Endpoints

### GET /api/v1/products

Retrieves all available products in the system.

#### Parameters

None required.

#### Response

```json
{
  "success": true,
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "MacBook Pro 14\"",
      "category": "laptop",
      "brand": "Apple",
      "model": "MacBook Pro",
      "sku": "MBP-14-001",
      "serial_number": "FVFZ14ABCD123",
      "condition": "new_condition",
      "status": "available",
      "purchase_price": 2499.99,
      "purchase_date": "2024-01-15T00:00:00Z",
      "warranty_expires": "2027-01-15T00:00:00Z",
      "description": "14-inch MacBook Pro with M2 Pro chip",
      "images": [
        {
          "id": "img-001",
          "filename": "macbook-pro-front.jpg",
          "content_type": "image/jpeg",
          "byte_size": 245760,
          "url": "https://example.com/storage/macbook-pro-front.jpg",
          "variants": {
            "thumbnail": "https://example.com/storage/macbook-pro-front-150x150.jpg",
            "medium": "https://example.com/storage/macbook-pro-front-400x400.jpg",
            "large": "https://example.com/storage/macbook-pro-front-800x800.jpg"
          }
        }
      ],
      "specifications": {
        "cpu": "Apple M2 Pro 12-core",
        "ram_size": "16GB",
        "ram_type": "LPDDR5",
        "storage_capacity": "512GB",
        "storage_type": "SSD",
        "gpu": "19-core GPU",
        "screen_size": "14.2 inches",
        "screen_resolution": "3024x1964",
        "battery_capacity": "70Wh",
        "ports": "3x Thunderbolt 4, HDMI, SDXC, MagSafe 3",
        "operating_system": "macOS Ventura",
        "weight": 1.6
      },
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-20T14:45:00Z"
    }
  ],
  "meta": {
    "total_count": 45,
    "product_type": "all",
    "cached": false,
    "generated_at": "2024-12-15T15:30:00Z"
  }
}
```

### GET /api/v1/products/{product_type}

Retrieves products filtered by category/type.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| product_type | string | Yes | Product category to filter by |

#### Valid Product Types

- `laptop` - Laptop computers
- `mouse` - Computer mice
- `keyboard` - Computer keyboards  
- `server` - Server equipment
- `desktop_pc` - Desktop computers
- `accessory` - Various accessories

#### Example Requests

```bash
# Get all laptops
GET /api/v1/products/laptop

# Get all mice
GET /api/v1/products/mouse

# Get all keyboards
GET /api/v1/products/keyboard

# Get all servers
GET /api/v1/products/server

# Get all desktop PCs
GET /api/v1/products/desktop_pc

# Get all accessories
GET /api/v1/products/accessory
```

#### Response

Same structure as the general products endpoint, but filtered by the specified type.

## Response Structure

### Success Response

```json
{
  "success": true,
  "data": [...], // Array of product objects
  "meta": {
    "total_count": 10,
    "product_type": "laptop",
    "cached": true,
    "generated_at": "2024-12-15T15:30:00Z"
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": "Error type",
  "message": "Human-readable error message"
}
```

## Product Object Schema

| Field | Type | Description |
|-------|------|-------------|
| id | string (UUID) | Unique identifier |
| name | string | Product name |
| category | string | Product category enum |
| brand | string | Manufacturer brand |
| model | string | Product model |
| sku | string | Stock Keeping Unit |
| serial_number | string | Manufacturer serial number |
| condition | string | Product condition (new_condition, used, refurbished) |
| status | string | Current status (available, allocated, in_service, retired, sold) |
| purchase_price | number | Purchase price in USD |
| purchase_date | string (ISO 8601) | Date of purchase |
| warranty_expires | string (ISO 8601) | Warranty expiration date |
| description | string | Product description |
| images | array | Array of image objects |
| specifications | object | Product-specific technical specifications |
| created_at | string (ISO 8601) | Record creation timestamp |
| updated_at | string (ISO 8601) | Record last update timestamp |

## Image Object Schema

| Field | Type | Description |
|-------|------|-------------|
| id | string | Image identifier |
| filename | string | Original filename |
| content_type | string | MIME type |
| byte_size | number | File size in bytes |
| url | string | Direct image URL |
| variants | object | Pre-generated image sizes |

### Image Variants

| Variant | Max Dimensions | Use Case |
|---------|----------------|----------|
| thumbnail | 150x150px | Lists, previews |
| medium | 400x400px | Cards, modals |
| large | 800x800px | Detail views, galleries |

## Specifications by Product Type

### Laptop Specifications

```json
{
  "cpu": "Processor model",
  "ram_size": "Memory amount",
  "ram_type": "Memory type",
  "storage_capacity": "Storage size",
  "storage_type": "Storage technology",
  "gpu": "Graphics card",
  "screen_size": "Display size",
  "screen_resolution": "Display resolution",
  "battery_capacity": "Battery specification",
  "ports": "Available ports",
  "operating_system": "Installed OS",
  "weight": "Device weight in kg"
}
```

### Mouse Specifications

```json
{
  "mouse_type": "Mouse type",
  "connection_type": "Connection method",
  "dpi": "DPI specification",
  "buttons_count": "Number of buttons",
  "features": "Additional features"
}
```

### Keyboard Specifications

```json
{
  "keyboard_type": "Keyboard type",
  "connection_type": "Connection method", 
  "layout": "Key layout",
  "switch_type": "Key switch type",
  "backlit": "Backlight status",
  "features": "Additional features"
}
```

### Server Specifications

```json
{
  "cpu": "Processor specification",
  "ram_size": "Memory amount",
  "storage_capacity": "Storage capacity",
  "storage_type": "Storage technology",
  "raid_config": "RAID configuration",
  "network_ports": "Network connectivity",
  "power_supply": "PSU specification",
  "form_factor": "Server form factor",
  "operating_system": "Server OS"
}
```

### Desktop PC Specifications

```json
{
  "cpu": "Processor specification",
  "ram_size": "Memory amount",
  "storage_capacity": "Storage capacity", 
  "storage_type": "Storage technology",
  "gpu": "Graphics card",
  "motherboard": "Motherboard model",
  "power_supply": "PSU specification",
  "case_type": "Case form factor",
  "operating_system": "Installed OS"
}
```

## HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request - Invalid parameters |
| 404 | Not Found - Invalid endpoint or product type |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

## Error Codes

### Rate Limiting Error (429)

```json
{
  "success": false,
  "error": "Rate limit exceeded",
  "message": "Too many requests. Limit: 100 requests per minute",
  "retry_after": 60
}
```

### Invalid Product Type (404)

```json
{
  "success": false,
  "error": "Not found",
  "message": "Invalid product type. Valid types: laptop, mouse, keyboard, server, desktop_pc, accessory"
}
```

### Server Error (500)

```json
{
  "success": false,
  "error": "Internal server error",
  "message": "An unexpected error occurred"
}
```

## Usage Examples

### JavaScript/Node.js

```javascript
// Fetch all products
fetch('/api/v1/products')
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      console.log(`Found ${data.meta.total_count} products`);
      data.data.forEach(product => {
        console.log(`${product.name} - ${product.category}`);
      });
    }
  });

// Fetch only laptops
fetch('/api/v1/products/laptop')
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      console.log(`Found ${data.meta.total_count} laptops`);
    }
  });
```

### Python

```python
import requests

# Fetch all products
response = requests.get('https://yourapi.com/api/v1/products')
if response.status_code == 200:
    data = response.json()
    if data['success']:
        print(f"Found {data['meta']['total_count']} products")
        for product in data['data']:
            print(f"{product['name']} - {product['category']}")

# Fetch only servers
response = requests.get('https://yourapi.com/api/v1/products/server')
if response.status_code == 200:
    data = response.json()
    print(f"Found {data['meta']['total_count']} servers")
```

### cURL

```bash
# Get all products
curl -X GET "https://yourapi.com/api/v1/products" \
  -H "Accept: application/json"

# Get laptops only
curl -X GET "https://yourapi.com/api/v1/products/laptop" \
  -H "Accept: application/json"

# With verbose output to see headers
curl -v -X GET "https://yourapi.com/api/v1/products" \
  -H "Accept: application/json"
```

## Security Features

### Input Validation
- Product type parameter validation against whitelist
- SQL injection prevention through parameter sanitization
- XSS prevention in response data

### Rate Limiting
- IP-based request throttling
- Configurable limits (default: 100/minute)
- Memory-efficient tracking

### Secure Headers
- CSRF protection disabled for API endpoints
- Standard Rails security headers maintained

### Error Handling
- Sanitized error responses (no sensitive data leaked)
- Comprehensive logging for debugging
- Graceful degradation for failures

## Performance Considerations

### Caching Strategy
- **Level**: Application-level caching
- **Duration**: 5 minutes
- **Invalidation**: Automatic on data changes
- **Storage**: Rails.cache (Memory/Redis)

### Database Optimization
- Optimized queries with includes for related data
- Indexed fields for filtering and sorting
- Polymorphic association handling

### Image Handling
- Multiple image variants pre-generated
- CDN-ready URLs
- Lazy loading compatible structure

## Monitoring and Analytics

### Recommended Metrics
- Request rate per endpoint
- Cache hit/miss ratios
- Response time percentiles
- Error rates by type
- Rate limiting trigger frequency

### Logging
- All API requests logged
- Error details captured
- Cache invalidation events tracked
- Rate limiting violations logged

## Best Practices for Consumers

### Caching
- Respect cache headers
- Implement client-side caching for repeated requests
- Consider ETags for conditional requests

### Error Handling
- Always check the `success` field
- Implement exponential backoff for rate limits
- Handle network errors gracefully

### Performance
- Use appropriate image variants for your use case
- Implement pagination for large datasets (if needed)
- Batch requests when possible

### Security
- Validate all data received from API
- Sanitize data before displaying to users
- Implement proper CORS headers if calling from browser

## Support and Feedback

For API support, questions, or feedback, please contact the development team or file an issue in the project repository.

---

*Last updated: December 15, 2024*
*API Version: 1.0.0*