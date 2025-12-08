# Ditronics Inventory - Quick Reference

## 🚀 Quick Start Commands

```bash
# Start the application
rails server

# Run background jobs
rails solid_queue:start

# Access at: http://localhost:3000
```

## 👤 Default Login

**Admin:**
- Email: `admin@ditronics.com`
- Password: `password123`

**Employee:**
- Email: `employee@ditronics.com`
- Password: `password123`

## 📊 Key Features by Role

### Admin Can:
- ✅ Full CRUD on laptops (Create, Read, Update, Delete)
- ✅ Record sales
- ✅ View all reports and statistics
- ✅ Clear application cache
- ✅ Manage users
- ✅ Delete any record

### Employee Can:
- ✅ Add new laptops
- ✅ Edit existing laptops
- ✅ Update laptop status
- ✅ Record sales
- ✅ View inventory
- ✅ View reports
- ❌ Cannot delete laptops

## 🖥️ Main Sections

### 1. Dashboard (/)
- Real-time statistics
- Recent sales
- Service alerts
- Quick action buttons

### 2. Laptops (/laptops)
- Full inventory listing
- Search & filter capabilities
- Add/Edit/Delete operations
- Multi-image upload support

### 3. Sales (/sales)
- Sales history
- Record new sales
- View transaction details
- Profit/loss calculations

## 📝 Common Tasks

### Add a New Laptop
1. Navigate to Laptops → "Add New Laptop"
2. Fill required fields (marked with *)
3. Upload images (optional)
4. Click "Create Laptop"

### Record a Sale
1. Navigate to Sales → "Record New Sale"
2. Select laptop from dropdown
3. Enter customer details
4. Set sale price
5. Click "Record Sale"

### Search Laptops
1. Go to Laptops page
2. Use search box for: Brand, Model, SKU, Serial Number
3. Use dropdowns to filter by Brand or Status
4. Click "Filter" to apply

### Update Laptop Status
1. Find laptop in inventory
2. Click "Edit"
3. Change Status dropdown
4. Save changes

## 🔍 Search & Filter Options

### Search supports:
- Brand name
- Model name
- SKU
- Serial number

### Filter by:
- Brand (dropdown populated from existing laptops)
- Status (Active, Sold, In Repair, Retired)

## 💾 Database Models

### Laptop Statuses
- **Active**: Available for use/sale
- **In Repair**: Currently being serviced
- **Retired**: No longer in use
- **Sold**: Sold to customer (auto-set on sale)

### Laptop Conditions
- **New**: Brand new device
- **Used**: Pre-owned
- **Refurbished**: Restored to good condition

## 🛠️ Admin-Only Features

### Clear Cache
Dashboard → "Clear Cache" button
Clears:
- Dashboard statistics cache
- Brand list cache

### Delete Records
Only admins can delete:
- Laptops
- Sales (restricted if referenced)

## 📸 Image Management

### Upload Images
- Multiple images supported per laptop
- Drag & drop or click to select
- Accepts: JPG, PNG, GIF, WebP

### Remove Images
- Edit laptop
- Click "Remove" under each image
- Confirms before deletion

### Auto-generated Variants
- Thumbnail: 300x200
- Medium: 800x600
- Large: 1200x900

## 🔔 Real-time Features

### Live Updates
- New laptop notifications
- Service reminders
- Powered by Action Cable (Solid Cable)

### Background Jobs
- Image processing (automatic on upload)
- Service reminders (scheduled)

## 📈 Reports & Analytics

### Dashboard Stats (Cached 15 min)
- Total laptops count
- Active/Sold/In Repair/Retired counts
- Total sales
- Total revenue
- Average sale price

### Sales Reports
- Recent 10 sales on dashboard
- Full history on Sales page
- Profit/loss per transaction

## ⚙️ Configuration Files

| File | Purpose |
|------|---------|
| `config/database.yml` | Database settings |
| `config/routes.rb` | URL routing |
| `config/deploy.yml` | Kamal deployment |
| `db/seeds.rb` | Sample data |

## 🐛 Troubleshooting

### Can't login?
- Check credentials
- Try password reset
- Verify user exists: `rails runner "puts User.count"`

### Images not displaying?
- Check Active Storage is installed
- Verify storage directory exists
- Run: `rails active_storage:install`

### Stats not updating?
- Clear cache (Admin → Dashboard → Clear Cache)
- Check cache is enabled in environment

### Background jobs not running?
- Start Solid Queue: `rails solid_queue:start`
- Check logs: `tail -f log/development.log`

## 📞 Rails Console Commands

```ruby
# Count users
User.count

# Find user by email
User.find_by(email: "admin@ditronics.com")

# Create new admin
User.create!(
  name: "New Admin",
  email: "new@example.com",
  password: "password",
  role: :admin
)

# Count laptops by status
Laptop.group(:status).count

# Clear all cache
Rails.cache.clear

# Reprocess all images
Laptop.find_each do |laptop|
  ProcessLaptopImagesJob.perform_later(laptop.id) if laptop.images.attached?
end
```

## 🔐 Security Notes

- Passwords hashed with bcrypt
- CSRF protection enabled
- Role-based authorization
- SQL injection protection via ActiveRecord
- Modern browser requirement enforced

## 📦 Technology Stack

- Rails 8.1.1
- Ruby 3.3.1
- PostgreSQL
- Solid Queue (background jobs)
- Solid Cache (caching)
- Solid Cable (WebSockets)
- Devise (authentication)
- Hotwire/Turbo (reactive UI)
- Active Storage (file uploads)

## 🚢 Deployment

### Development
```bash
rails server
```

### Production (Kamal)
```bash
kamal deploy
```

## 📚 Documentation

- **README.md**: Full documentation
- **SETUP_GUIDE.md**: Detailed setup instructions
- **This file**: Quick reference

---

**Need help?** Check the full README.md or SETUP_GUIDE.md
