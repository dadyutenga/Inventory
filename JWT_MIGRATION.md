# JWT Authentication Migration Complete

## ✅ Migration Summary

The Ditronics Inventory application has been successfully migrated from **Devise** authentication to **JWT (JSON Web Token)** authentication while preserving all existing features.

---

## 🔑 Authentication System

### Architecture
- **Token Type**: JWT (JSON Web Tokens)
- **Password Hashing**: bcrypt via `has_secure_password`
- **Token Storage**: 
  - API requests: `Authorization: Bearer <token>` header
  - Browser/ERB requests: Rails session (compatible with Turbo/Hotwire)
- **Token Expiration**: 24 hours
- **Secret Key**: Stored in `Rails.application.credentials.jwt_secret_key` (fallback: `secret_key_base`)

---

## 📡 API Endpoints

### Authentication Routes

#### **POST /login**
Login with email and password.

**Request (JSON):**
```json
{
  "email": "admin@ditronics.com",
  "password": "password123"
}
```

**Response (Success):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "admin@ditronics.com",
    "name": "Admin User",
    "role": "admin"
  }
}
```

**Response (Error):**
```json
{
  "error": "Invalid email or password"
}
```

---

#### **POST /register**
Create a new user account.

**Request (JSON):**
```json
{
  "user": {
    "name": "John Doe",
    "email": "john@ditronics.com",
    "password": "securepass123",
    "password_confirmation": "securepass123",
    "role": "employee"
  }
}
```

**Response (Success):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 3,
    "email": "john@ditronics.com",
    "name": "John Doe",
    "role": "employee"
  }
}
```

**Response (Error):**
```json
{
  "errors": [
    "Email has already been taken",
    "Password is too short (minimum is 6 characters)"
  ]
}
```

---

#### **DELETE /logout**
Logout (client-side token removal).

**Response (JSON):**
```json
{
  "message": "Logged out successfully"
}
```

**Note:** For stateless JWT, logout is typically handled client-side by deleting the token. The server endpoint is provided for consistency.

---

### Protected Endpoints

All existing routes require authentication:
- **Laptops**: `/laptops` (index, show, new, create, edit, update, destroy*)
- **Sales**: `/sales` (index, new, create, show)
- **Dashboard**: `/dashboard` (index)

**Admin-only actions** (marked with *):
- DELETE `/laptops/:id` - Delete laptop (admin only)

---

## 🔐 Authorization

### Roles
- **Employee**: Can view, create, and edit laptops and sales
- **Admin**: Full access including deletion of laptops

### Role-Based Access Control
Authorization is enforced in controllers:
- `before_action :authenticate_user` - Requires valid JWT
- `before_action :authorize_admin!` - Requires admin role

Example:
```ruby
class LaptopsController < ApplicationController
  before_action :authenticate_user
  before_action :authorize_admin!, only: [:destroy]
end
```

---

## 🌐 Browser Access (ERB Views)

### Login Page
- **URL**: `GET /login`
- **View**: `app/views/auth/login.html.erb`
- Traditional HTML form that POSTs to `/login`
- Stores JWT in session for subsequent requests

### Register Page
- **URL**: `GET /register`
- **View**: `app/views/users/register.html.erb`
- Traditional HTML form that POSTs to `/register`
- Stores JWT in session after successful registration

### Session Management
For browser-based requests, the JWT is stored in `session[:auth_token]` and automatically included in subsequent requests. This ensures compatibility with Turbo/Hotwire and traditional Rails views.

---

## 🧪 Testing Authentication

### Using cURL (API)

**Login:**
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ditronics.com","password":"password123"}'
```

**Access Protected Route:**
```bash
curl http://localhost:3000/laptops.json \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Register:**
```bash
curl -X POST http://localhost:3000/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Test User",
      "email": "test@ditronics.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'
```

### Using Browser
1. Navigate to `http://localhost:3000/login`
2. Enter credentials:
   - **Admin**: `admin@ditronics.com` / `password123`
   - **Employee**: `employee@ditronics.com` / `password123`
3. Access dashboard, laptops, and sales via navigation

---

## 📂 Changed Files

### New Files
1. **`app/services/json_web_token.rb`** - JWT encoding/decoding service
2. **`lib/exception_handler.rb`** - JWT exception handling module
3. **`app/controllers/auth_controller.rb`** - Login/logout actions
4. **`app/controllers/users_controller.rb`** - Registration action
5. **`app/views/auth/login.html.erb`** - Login page
6. **`app/views/users/register.html.erb`** - Registration page
7. **`db/migrate/20251208020336_add_password_digest_to_users.rb`** - Added password_digest column

### Modified Files
1. **`Gemfile`** - Enabled bcrypt gem
2. **`app/models/user.rb`** - Replaced Devise with `has_secure_password`
3. **`app/controllers/application_controller.rb`** - Added JWT authentication methods
4. **`app/controllers/laptops_controller.rb`** - Changed `authenticate_user!` to `authenticate_user`
5. **`app/controllers/sales_controller.rb`** - Changed `authenticate_user!` to `authenticate_user`
6. **`app/controllers/dashboard_controller.rb`** - Changed `authenticate_user!` to `authenticate_user`
7. **`config/routes.rb`** - Added JWT routes, commented out Devise routes
8. **`app/views/layouts/application.html.erb`** - Updated logout link

---

## 🔧 Implementation Details

### User Model
```ruby
class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, allow_nil: true
  
  before_save :downcase_email
  
  enum :role, { employee: 0, admin: 1 }, default: :employee
  
  has_many :laptops, foreign_key: :allocated_to_id
  has_many :sales, foreign_key: :sold_by_id
  
  private
  
  def downcase_email
    self.email = email.downcase
  end
end
```

### JWT Service
```ruby
class JsonWebToken
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key)
  end

  def self.decode(token)
    body = JWT.decode(token, secret_key)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::ExpiredSignature
    raise ExceptionHandler::ExpiredSignature
  rescue JWT::DecodeError
    raise ExceptionHandler::DecodeError
  end

  private

  def self.secret_key
    Rails.application.credentials.jwt_secret_key || 
      Rails.application.credentials.secret_key_base
  end
end
```

### ApplicationController Authentication
```ruby
def authenticate_user
  # Try Authorization header first (API), then session (browser)
  header = request.headers['Authorization']
  token = header.split(' ').last if header
  token ||= session[:auth_token]

  raise ExceptionHandler::MissingToken unless token

  decoded = JsonWebToken.decode(token)
  @current_user = User.find(decoded[:user_id])
rescue ActiveRecord::RecordNotFound
  raise ExceptionHandler::InvalidToken
end
```

---

## 🚀 Next Steps (Optional)

### 1. Remove Devise Completely
If you're fully satisfied with JWT:
```ruby
# Gemfile - remove this line:
gem "devise"

# config/routes.rb - already commented out:
# devise_for :users

# Delete Devise views (optional):
rm -rf app/views/devise
```

Then run:
```bash
bundle install
rails db:migrate:status  # Verify no Devise migrations are pending
```

### 2. Token Blacklisting (Advanced)
For logout to invalidate tokens server-side, implement a token blacklist:
- Create a `BlacklistedTokens` model
- Store revoked JTIs (JWT IDs)
- Check blacklist in `authenticate_user`

### 3. Refresh Tokens
For longer sessions without frequent re-login:
- Issue short-lived access tokens (15 min)
- Issue long-lived refresh tokens (7 days)
- Add `/refresh` endpoint to exchange refresh for new access token

### 4. Rate Limiting
Protect authentication endpoints from brute-force:
- Use `rack-attack` gem
- Limit login attempts per IP/email

---

## 📊 Feature Parity Checklist

✅ **All original features preserved:**
- [x] User authentication (admin/employee roles)
- [x] Laptop CRUD operations (40+ specification fields)
- [x] Sales tracking and management
- [x] Dashboard with cached statistics
- [x] Background jobs (ProcessLaptopImagesJob, ServiceReminderJob)
- [x] Real-time features (AlertsChannel)
- [x] Active Storage (multiple images per laptop)
- [x] Search and filtering
- [x] Turbo/Hotwire reactive UI
- [x] ERB template views
- [x] Role-based authorization
- [x] Admin-only actions

✅ **New JWT features:**
- [x] Stateless token authentication
- [x] API-friendly JSON responses
- [x] Session-based browser compatibility
- [x] Token expiration (24 hours)
- [x] Secure password hashing (bcrypt)
- [x] RESTful auth endpoints

---

## 🔍 Troubleshooting

### Token Not Working
- Ensure token is sent as `Authorization: Bearer <token>`
- Check token hasn't expired (24 hour limit)
- Verify user still exists in database

### Browser Login Issues
- Clear browser cookies/session
- Check Rails logs for authentication errors
- Verify `session[:auth_token]` is being set

### Password Issues
- Minimum 6 characters required
- Password confirmation must match
- Email must be unique and valid format

---

## 📝 Credentials Management

To set a custom JWT secret:
```bash
EDITOR="code --wait" rails credentials:edit
```

Add this line:
```yaml
jwt_secret_key: your_very_long_random_secret_key_here
```

Generate a secure key:
```bash
rails secret
```

---

## ✨ Migration Complete!

Your Ditronics Inventory app now uses **JWT authentication** with full backward compatibility for ERB views and Turbo/Hotwire. All original features are intact and working.

**Default Credentials:**
- Admin: `admin@ditronics.com` / `password123`
- Employee: `employee@ditronics.com` / `password123`

For questions or issues, refer to the main documentation in `README.md` and `QUICK_REFERENCE.md`.
