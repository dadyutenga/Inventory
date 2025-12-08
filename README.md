# Ditronics Inventory Management System

A comprehensive laptop inventory management web application built with **Ruby on Rails 8.1.1** for Ditronics. This system provides complete laptop tracking, sales management, reporting, and real-time updates using modern Rails technologies.

## 🚀 Technology Stack

- **Ruby 3.3.1**
- **Rails 8.1.1**
- **PostgreSQL** - Primary database
- **JWT + bcrypt** - Token-based authentication with Admin/Employee roles (see [JWT_MIGRATION.md](JWT_MIGRATION.md))
- **Solid Queue** - Background job processing (no Redis)
- **Solid Cache** - High-performance caching (no Redis)
- **Solid Cable** - Action Cable for WebSockets (no Redis)
- **Active Storage** - Multiple image uploads per laptop
- **Hotwire (Turbo + Stimulus)** - Fast, reactive UI
- **Thruster** - HTTP/2, asset caching, and compression
- **Puma** - Application server
- **Kamal** - Deployment automation

## ✨ Features

### 1. User Management & Authentication
- **JWT-based authentication** (stateless, API-friendly)
- **Role-based access control:**
  - **Admin**: Full CRUD operations, reports, cache management
  - **Employee**: Add laptops, update status, view inventory
- Secure password hashing with bcrypt
- 24-hour token expiration
- Browser and API support
- See [JWT_MIGRATION.md](JWT_MIGRATION.md) for authentication details

### 2. Comprehensive Laptop Inventory
Each laptop record stores extensive specifications:

**Basic Information:**
- SKU, Vendor/Supplier, Brand, Model, Model Number
- Serial Number (unique), Purchase Date, Purchase Price
- Condition (New, Used, Refurbished)

**Hardware Specifications:**
- CPU, CPU Generation, GPU
- RAM Size, RAM Type
- Storage Capacity, Storage Type (HDD/SSD/NVMe)
- Screen Size, Screen Resolution, Display Type (IPS/TN/OLED)
- Keyboard Type, Keyboard Backlight
- Battery Capacity
- Webcam, Microphone
- WiFi Type, Bluetooth Version
- Ports (detailed listing)
- Weight

**Software & OS:**
- Operating System
- License Key

**Status & Tracking:**
- Status (Active, In Repair, Retired, Sold)
- Allocated To (Employee assignment)
- Last Service Date
- Next Service Due
- Notes (text field for additional information)

**Images:**
- Multiple photo uploads via Active Storage
- Automatic thumbnail generation
- Image variant processing via background jobs

### 3. Sales Management
- Record laptop sales with complete transaction details
- Auto-update laptop status to "sold"
- Track:
  - Customer name
  - Sale date & time
  - Sale price
  - Sold by (employee)
  - Invoice reference
  - Profit/loss calculation

### 4. Dashboard & Reports
- **Real-time statistics (cached for performance):**
  - Total laptops
  - Active, Sold, In Repair, Retired counts
  - Total sales and revenue
  - Average sale price
- Recent sales history
- Recent laptop additions
- Service due alerts
- Quick action buttons

### 5. Search & Filtering
- Search laptops by:
  - Brand, Model
  - SKU, Serial Number
- Filter by:
  - Brand
  - Status (Active, Sold, In Repair, Retired)
  - Multiple criteria simultaneously

### 6. Background Processing
- **Image Processing Job**: Automatically generates image variants (thumbnails, medium, large)
- **Service Reminder Job**: Sends alerts for laptops needing service
- All jobs powered by Solid Queue (no Redis required)

### 7. Real-time Updates
- Action Cable integration with Solid Cable
- Live notifications when new laptops are added
- Service alerts broadcast to connected users
- No Redis dependency

### 8. Caching Strategy
- Dashboard statistics cached for 15 minutes
- Brand list cached for 1 hour
- Admin can manually clear cache
- Powered by Solid Cache

## 📋 Prerequisites

- Ruby 3.3.1
- PostgreSQL 13+
- Node.js (for asset compilation)
- Bundler 2.x

## 🛠️ Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Inventory
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Configure Database

Edit `config/database.yml` with your PostgreSQL credentials:

```yaml
development:
  adapter: postgresql
  database: mydb
  username: postgres
  password: your_password
  host: localhost
```

### 4. Setup Database

```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate

# Seed sample data
rails db:seed
```

### 5. Start the Server

```bash
rails server
```

Visit: **http://localhost:3000**

## 👥 Default Login Credentials

After running `rails db:seed`:

**Admin User:**
- Email: `admin@ditronics.com`
- Password: `password123`

**Employee User:**
- Email: `employee@ditronics.com`
- Password: `password123`

## 📁 Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── dashboard_controller.rb      # Dashboard with stats & reports
│   ├── laptops_controller.rb        # CRUD for laptops
│   └── sales_controller.rb          # Sales tracking
├── models/
│   ├── user.rb                      # Devise user with roles
│   ├── laptop.rb                    # Laptop inventory
│   └── sale.rb                      # Sales transactions
├── views/
│   ├── dashboard/
│   │   └── index.html.erb           # Dashboard view
│   ├── laptops/
│   │   ├── index.html.erb           # Laptop listing
│   │   ├── show.html.erb            # Laptop details
│   │   ├── new.html.erb             # Add laptop
│   │   ├── edit.html.erb            # Edit laptop
│   │   └── _form.html.erb           # Laptop form partial
│   ├── sales/
│   │   ├── index.html.erb           # Sales history
│   │   ├── new.html.erb             # Record sale
│   │   └── show.html.erb            # Sale details
│   └── layouts/
│       └── application.html.erb      # Main layout with nav
├── jobs/
│   ├── process_laptop_images_job.rb  # Image variant generation
│   └── service_reminder_job.rb       # Service alerts
└── channels/
    └── alerts_channel.rb             # Real-time notifications

config/
├── database.yml                      # Database configuration
├── routes.rb                         # Application routes
└── environments/
    ├── development.rb                # Dev environment settings
    ├── production.rb                 # Production settings
    └── test.rb                       # Test settings

db/
├── migrate/                          # Database migrations
├── schema.rb                         # Database schema
└── seeds.rb                          # Sample data
```

## 🔑 Key Models & Associations

### User
- `has_many :laptops_allocated` (laptops assigned to user)
- `has_many :sales` (sales made by user)
- Enum roles: `admin`, `employee`

### Laptop
- `belongs_to :allocated_to` (User, optional)
- `has_one :sale`
- `has_many_attached :images`
- Enum condition: `new_condition`, `used`, `refurbished`
- Enum status: `active`, `in_repair`, `retired`, `sold`

### Sale
- `belongs_to :laptop`
- `belongs_to :sold_by` (User)
- Auto-updates laptop status to `sold` after creation

## 🚢 Deployment with Kamal

The application is configured for deployment with Kamal:

```bash
# Deploy to production
kamal deploy

# Check deployment status
kamal details

# View logs
kamal logs
```

Configuration file: `config/deploy.yml`

## 🧪 Running Tests

```bash
# Run all tests
rails test

# Run specific test
rails test test/models/laptop_test.rb

# Run system tests
rails test:system
```

## 📊 Background Jobs

### Process Laptop Images
Automatically generates image variants when laptop images are uploaded:
- Thumbnail: 300x200
- Medium: 800x600
- Large: 1200x900

### Service Reminder
Sends real-time alerts for laptops needing service within 7 days.

## 🔧 Administrative Tasks

### Clear Cache (Admin only)
```ruby
# Via UI: Dashboard → Clear Cache button
# Via console:
Rails.cache.clear
```

### Create New Admin User
```ruby
rails console

User.create!(
  name: "New Admin",
  email: "newadmin@ditronics.com",
  password: "securepassword",
  password_confirmation: "securepassword",
  role: :admin
)
```

## 🎨 UI Features

- Responsive design
- Real-time updates via Turbo
- Image galleries
- Advanced filtering
- Status badges
- Flash notifications
- Role-based navigation

## 📈 Performance Optimizations

- Solid Cache for dashboard statistics
- Eager loading of associations
- Image variant caching
- Database indexes on serial_number and email
- Fragment caching where applicable

## 🔒 Security Features

- CSRF protection
- SQL injection prevention via ActiveRecord
- Role-based authorization
- Secure password storage (bcrypt via Devise)
- Content Security Policy headers

## 📝 License

This project is proprietary software for Ditronics.

## 👨‍💻 Support

For issues or questions, contact the development team.

---

**Built with ❤️ using Rails 8.1.1**
