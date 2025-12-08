# Ditronics Inventory - Quick Setup Guide

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] Ruby 3.3.1 installed (`ruby -v`)
- [ ] PostgreSQL 13+ installed and running (`psql --version`)
- [ ] Bundler installed (`bundle -v`)
- [ ] Git installed (`git --version`)

## Step-by-Step Setup

### 1. Database Configuration

Update `config/database.yml` with your PostgreSQL credentials:

```yaml
development:
  adapter: postgresql
  database: mydb
  username: your_postgres_username
  password: your_postgres_password
  host: localhost
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Database Setup

```bash
# Create the database
rails db:create

# Run all migrations
rails db:migrate

# Load sample data
rails db:seed
```

### 4. Verify Installation

```bash
# Check if migrations are up to date
rails db:migrate:status

# Verify users were created
rails runner "puts User.count"  # Should output: 2
```

### 5. Start the Application

```bash
# Development server
rails server

# Or use Thruster for production-like experience
thruster start
```

### 6. Access the Application

Open your browser and navigate to:
```
http://localhost:3000
```

### 7. Login

**Admin Account:**
- Email: `admin@ditronics.com`
- Password: `password123`

**Employee Account:**
- Email: `employee@ditronics.com`
- Password: `password123`

## Post-Setup Tasks

### Start Background Jobs (Solid Queue)

In a separate terminal:

```bash
rails solid_queue:start
```

This enables:
- Image processing jobs
- Service reminder notifications

### Verify Solid Cache

```bash
rails runner "Rails.cache.write('test', 'value'); puts Rails.cache.read('test')"
# Should output: value
```

### Verify Solid Cable (Action Cable)

Action Cable is configured to use Solid Cable (no Redis required).
Real-time features will work automatically when the server is running.

## Common Issues & Solutions

### Issue: Database Connection Error

**Solution:**
1. Verify PostgreSQL is running: `sudo service postgresql status`
2. Check credentials in `config/database.yml`
3. Ensure the database exists: `rails db:create`

### Issue: Migration Errors

**Solution:**
```bash
# Reset database (WARNING: destroys all data)
rails db:drop db:create db:migrate db:seed
```

### Issue: Permission Errors

**Solution:**
```bash
# Ensure proper file permissions
chmod +x bin/rails
chmod +x bin/setup
```

### Issue: Missing Gems

**Solution:**
```bash
bundle install
bundle update
```

## Development Workflow

### Adding New Laptops
1. Navigate to "Laptops" → "Add New Laptop"
2. Fill in all required fields (marked with *)
3. Upload images (optional, but recommended)
4. Save

### Recording a Sale
1. Navigate to "Sales" → "Record New Sale"
2. Select the laptop to sell
3. Enter customer information
4. Set sale price
5. Record sale (laptop status automatically updates to "sold")

### Viewing Reports
1. Navigate to "Dashboard"
2. View statistics, recent sales, and alerts
3. Use filters on laptop index page for detailed searches

## Admin-Only Features

When logged in as admin:
- Delete laptops
- Clear application cache
- View all user activities
- Access to all CRUD operations

## Testing

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/laptop_test.rb

# Run system tests (requires Chrome/Chromium)
rails test:system
```

## Production Deployment (Kamal)

### Prerequisites
- Docker installed on production server
- SSH access to production server
- Domain name configured

### Deploy

```bash
# First-time setup
kamal setup

# Deploy updates
kamal deploy

# Check status
kamal details

# View logs
kamal logs
```

## Environment Variables (Production)

Create `.env` file with:

```env
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_here
DATABASE_URL=postgres://user:pass@host:5432/dbname
INVENTORY_DATABASE_PASSWORD=your_db_password
```

Generate secret key:
```bash
rails secret
```

## Backup & Restore

### Backup Database

```bash
pg_dump -U postgres mydb > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
psql -U postgres mydb < backup_20240101.sql
```

## Maintenance Tasks

### Clear Cache

Via Rails console:
```bash
rails console
Rails.cache.clear
```

Or via UI (Admin only):
Dashboard → "Clear Cache" button

### Check Solid Queue Jobs

```bash
rails solid_queue:status
```

### Reprocess Images

```bash
rails runner "Laptop.find_each { |l| ProcessLaptopImagesJob.perform_later(l.id) if l.images.attached? }"
```

## Getting Help

- Check logs: `tail -f log/development.log`
- Rails console: `rails console`
- Database console: `rails dbconsole`

## Next Steps

1. **Customize branding**: Update logo, colors in `app/views/layouts/application.html.erb`
2. **Add more users**: Via Dashboard or Rails console
3. **Configure email**: Update mailer settings in `config/environments/production.rb`
4. **Set up monitoring**: Add error tracking (e.g., Sentry, Rollbar)
5. **Performance tuning**: Configure Puma threads/workers in `config/puma.rb`

## Important Files

- **Routes**: `config/routes.rb`
- **Database Schema**: `db/schema.rb`
- **Seeds**: `db/seeds.rb`
- **Environment Config**: `config/environments/*.rb`
- **Kamal Deploy**: `config/deploy.yml`

---

**Your Ditronics Inventory System is ready to use!** 🎉
