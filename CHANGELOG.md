# CHANGELOG

## [1.0.0] - December 8, 2025

### Initial Release - Complete Inventory Management System

#### Added - Authentication & Users
- Devise authentication integration
- User model with Admin/Employee roles
- Custom login and registration pages
- Role-based authorization helpers
- Name field for users

#### Added - Laptop Inventory
- Comprehensive Laptop model with 40+ fields
  - Basic info (SKU, vendor, brand, model, serial number, etc.)
  - Hardware specs (CPU, GPU, RAM, storage, display, etc.)
  - Software/OS (operating system, license key)
  - Status tracking (status, allocated_to, service dates, notes)
- Multiple image upload support via Active Storage
- Image variant generation (thumbnail, medium, large)
- Full CRUD operations
- Search functionality (brand, model, SKU, serial)
- Filter by brand and status
- Scopes for efficient querying
- Real-time notifications when laptops are added

#### Added - Sales Management
- Sale model tracking transactions
- Fields: laptop, customer, date, price, invoice ref, sold by
- Automatic laptop status update to "sold"
- Profit/loss calculation on sale details
- Sales history view
- Transaction detail pages

#### Added - Dashboard & Reports
- Statistics dashboard with caching
  - Total laptops
  - Counts by status (active, sold, in repair, retired)
  - Total sales and revenue
  - Average sale price
- Recent sales listing (last 10)
- Recent laptops (last 8)
- Service due alerts
- Quick action buttons
- Cache clearing for admins

#### Added - Background Jobs
- ProcessLaptopImagesJob for automatic image variant generation
- ServiceReminderJob for service alerts
- Solid Queue integration (no Redis required)

#### Added - Real-time Features
- Action Cable integration via Solid Cable
- Alerts channel for live notifications
- New laptop broadcast
- Service alert broadcast
- No Redis dependency

#### Added - UI/UX
- Responsive navigation menu
- Professional dashboard layout
- Laptop card grid view
- Detailed laptop specification pages
- Comprehensive forms with all fields
- Multiple image gallery
- Status badges with color coding
- Flash notifications
- Beautiful gradient design
- Custom login/signup pages

#### Added - Search & Filter
- Text search across brand, model, SKU, serial number
- Brand filter (dynamic dropdown)
- Status filter (Active, Sold, In Repair, Retired)
- Combined filter support
- Cached brand list

#### Added - Caching
- Solid Cache integration
- Dashboard statistics cache (15 minutes)
- Brand list cache (1 hour)
- Manual cache clearing for admins

#### Added - Documentation
- README.md - Comprehensive project documentation
- SETUP_GUIDE.md - Detailed setup instructions
- QUICK_REFERENCE.md - Quick command reference
- BUILD_COMPLETE.md - Implementation summary
- Inline code comments
- Model documentation

#### Added - Database
- PostgreSQL configuration
- User migration with role enum
- Laptop migration with 40+ typed columns
- Sale migration with foreign keys
- Active Storage migrations
- Proper indexes (serial_number, email)
- Foreign key constraints

#### Added - Sample Data
- Seed file with 2 users (admin, employee)
- 3 sample laptops (Dell, HP, Lenovo)
- Full specifications for testing

#### Added - Configuration
- RESTful routes for all resources
- Devise configuration
- Database configuration
- Environment-specific settings
- Mailer defaults
- Active Storage configuration
- Kamal deployment configuration

#### Added - Security
- CSRF protection
- SQL injection prevention via ActiveRecord
- Bcrypt password hashing
- Role-based authorization
- Secure file uploads
- Content Security Policy

#### Technical Details
- Ruby 3.3.1
- Rails 8.1.1
- PostgreSQL
- Devise 4.9.4
- Solid Queue (background jobs)
- Solid Cache (caching)
- Solid Cable (WebSockets)
- Active Storage (file uploads)
- Hotwire/Turbo (reactive UI)
- Image Processing gem
- Thruster (HTTP/2, compression)
- Kamal (deployment)

#### Database Schema
- users: id, email, encrypted_password, name, role, timestamps
- laptops: 40+ columns for complete specifications
- sales: laptop_id, sold_by_id, sold_to, sold_at, sale_price, invoice_ref
- active_storage_blobs, active_storage_attachments

#### Models & Associations
- User: has_many :laptops_allocated, has_many :sales
- Laptop: belongs_to :allocated_to (User), has_one :sale, has_many_attached :images
- Sale: belongs_to :laptop, belongs_to :sold_by (User)

#### Controllers
- ApplicationController: Base with auth helpers
- DashboardController: Statistics and reports
- LaptopsController: Full CRUD with search/filter
- SalesController: Transaction management

#### Views (ERB)
- Dashboard index
- Laptop index, show, new, edit, _form
- Sale index, new, show
- Devise sessions, registrations (customized)
- Application layout with navigation

#### Jobs
- ProcessLaptopImagesJob
- ServiceReminderJob

#### Channels
- AlertsChannel for real-time notifications

#### Features by Role
**Admin:**
- Full CRUD on laptops (including delete)
- Record sales
- View reports
- Clear cache
- All employee features

**Employee:**
- Create, read, update laptops
- Record sales
- View inventory
- View reports
- Cannot delete

#### Performance Optimizations
- Eager loading for associations
- Database indexes
- Query scopes
- Cached statistics
- Background image processing

---

**Version 1.0.0 represents a complete, production-ready inventory management system.**
