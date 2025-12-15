# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Note: With UUID primary keys, we use find_or_create_by with unique fields like email/serial_number

# Create admin user
admin = User.find_or_create_by!(email: "admin@ditronics.com") do |user|
  user.name = "Admin User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
end

# Create employee user
employee = User.find_or_create_by!(email: "employee@ditronics.com") do |user|
  user.name = "Employee User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :employee
end

puts "Created users:"
puts "  Admin: admin@ditronics.com / password123"
puts "  Employee: employee@ditronics.com / password123"

def create_product_with(item:, attrs: {}, product_attrs: {})
  Product.find_or_create_by!(serial_number: product_attrs[:serial_number]) do |product|
    product.name = product_attrs[:name]
    product.category = product_attrs[:category]
    product.sku = product_attrs[:sku]
    product.serial_number = product_attrs[:serial_number]
    product.vendor = product_attrs[:vendor]
    product.brand = product_attrs[:brand]
    product.model = product_attrs[:model]
    product.model_number = product_attrs[:model_number]
    product.location = product_attrs[:location]
    product.status = product_attrs[:status]
    product.condition = product_attrs[:condition]
    product.purchase_date = product_attrs[:purchase_date]
    product.purchase_price = product_attrs[:purchase_price]
    product.last_service_date = product_attrs[:last_service_date]
    product.next_service_due = product_attrs[:next_service_due]
    product.notes = product_attrs[:notes]
    product.allocated_to = product_attrs[:allocated_to]
    product.productable = item.new(attrs)
  end
end

# Sample laptops
create_product_with(
  item: Laptop,
  attrs: {
    cpu: "Intel Core i7-1185G7",
    cpu_generation: "11th Gen",
    gpu: "Intel Iris Xe Graphics",
    ram_size: "16GB",
    ram_type: "DDR4",
    storage_capacity: "512GB",
    storage_type: "NVMe SSD",
    screen_size: "14 inches",
    screen_resolution: "1920x1080 (Full HD)",
    display_type: "IPS",
    keyboard_type: "Chiclet",
    keyboard_backlight: true,
    battery_capacity: "63Wh",
    webcam: true,
    microphone: true,
    wifi_type: "WiFi 6 (802.11ax)",
    bluetooth_version: "5.1",
    ports: "2x USB-A 3.2, 2x USB-C Thunderbolt 4, HDMI 2.0, RJ45, 3.5mm audio",
    weight: "1.4 kg",
    operating_system: "Windows 11 Pro",
    license_key: "WIN11-XXXXX-XXXXX-XXXXX"
  },
  product_attrs: {
    name: "Dell Latitude 5420",
    category: :laptop,
    sku: "DIT-001",
    serial_number: "DELL-SN-001",
    vendor: "Tech Distributors Inc",
    brand: "Dell",
    model: "Latitude 5420",
    model_number: "LAT-5420-I7",
    status: :available,
    condition: :new_condition,
    purchase_date: 6.months.ago,
    purchase_price: 1200.00,
    allocated_to: employee,
    notes: "Excellent business laptop for office work"
  }
)

create_product_with(
  item: Laptop,
  attrs: {
    cpu: "Intel Core i7-1165G7",
    cpu_generation: "11th Gen",
    gpu: "Intel Iris Xe Graphics",
    ram_size: "32GB",
    ram_type: "DDR4",
    storage_capacity: "1TB",
    storage_type: "NVMe SSD",
    screen_size: "14 inches",
    screen_resolution: "1920x1080 (Full HD)",
    display_type: "IPS",
    keyboard_type: "Chiclet",
    keyboard_backlight: true,
    battery_capacity: "56Wh",
    webcam: true,
    microphone: true,
    wifi_type: "WiFi 6 (802.11ax)",
    bluetooth_version: "5.0",
    ports: "2x USB-A 3.2, 2x USB-C Thunderbolt 4, HDMI 2.0, 3.5mm audio",
    weight: "1.3 kg",
    operating_system: "Windows 11 Pro",
    license_key: "WIN11-YYYYY-YYYYY-YYYYY"
  },
  product_attrs: {
    name: "HP EliteBook 840 G8",
    category: :laptop,
    sku: "DIT-002",
    serial_number: "HP-SN-002",
    vendor: "HP Enterprise",
    brand: "HP",
    model: "EliteBook 840 G8",
    model_number: "EB840-G8",
    status: :available,
    condition: :new_condition,
    purchase_date: 4.months.ago,
    purchase_price: 1450.00,
    notes: "High-performance laptop for developers"
  }
)

create_product_with(
  item: Laptop,
  attrs: {
    cpu: "Intel Core i7-1185G7",
    cpu_generation: "11th Gen",
    gpu: "Intel Iris Xe Graphics",
    ram_size: "16GB",
    ram_type: "LPDDR4X",
    storage_capacity: "512GB",
    storage_type: "NVMe SSD",
    screen_size: "14 inches",
    screen_resolution: "2560x1600 (WQXGA)",
    display_type: "IPS",
    keyboard_type: "Chiclet",
    keyboard_backlight: true,
    battery_capacity: "57Wh",
    webcam: true,
    microphone: true,
    wifi_type: "WiFi 6E (802.11ax)",
    bluetooth_version: "5.2",
    ports: "2x USB-C Thunderbolt 4, 2x USB-A 3.2, HDMI 2.0, 3.5mm audio",
    weight: "1.13 kg",
    operating_system: "Windows 11 Pro",
    license_key: "WIN11-ZZZZZ-ZZZZZ-ZZZZZ"
  },
  product_attrs: {
    name: "Lenovo ThinkPad X1 Carbon Gen 9",
    category: :laptop,
    sku: "DIT-003",
    serial_number: "LENOVO-SN-003",
    vendor: "Lenovo Direct",
    brand: "Lenovo",
    model: "ThinkPad X1 Carbon Gen 9",
    model_number: "X1C-G9",
    status: :in_service,
    condition: :refurbished,
    purchase_date: 3.months.ago,
    purchase_price: 1800.00,
    last_service_date: 1.week.ago,
    next_service_due: 2.weeks.from_now,
    notes: "Ultralight premium laptop, currently in repair for keyboard replacement"
  }
)

# Desktop PC
create_product_with(
  item: DesktopPc,
  attrs: {
    cpu: "Intel Core i5-11500",
    ram_size: "16GB",
    storage_capacity: "512GB",
    storage_type: "NVMe SSD",
    gpu: "Integrated UHD",
    form_factor: "SFF"
  },
  product_attrs: {
    name: "Dell OptiPlex 7090",
    category: :desktop_pc,
    sku: "DIT-004",
    serial_number: "DESKTOP-SN-004",
    vendor: "Custom Build",
    brand: "Dell",
    model: "OptiPlex 7090",
    model_number: "OPX7090-SFF",
    status: :available,
    condition: :used,
    purchase_date: 5.months.ago,
    purchase_price: 950.00,
    notes: "Front-desk desktop PC"
  }
)

# Server
create_product_with(
  item: Server,
  attrs: {
    cpu_model: "Intel Xeon Silver 4210",
    cpu_count: 2,
    ram_size: "64GB",
    storage_capacity: "4x1TB",
    storage_type: "SAS HDD",
    raid_level: "RAID10",
    operating_system: "VMware ESXi",
    rack_units: "2U"
  },
  product_attrs: {
    name: "HPE ProLiant DL380 Gen10",
    category: :server,
    sku: "DIT-005",
    serial_number: "SERVER-SN-005",
    vendor: "HPE",
    brand: "HPE",
    model: "ProLiant DL380 Gen10",
    model_number: "DL380-G10",
    status: :available,
    condition: :used,
    purchase_date: 1.year.ago,
    purchase_price: 4200.00,
    notes: "Virtualization host"
  }
)

# Keyboard
create_product_with(
  item: Keyboard,
  attrs: {
    layout: "ANSI",
    switch_type: "Scissor",
    backlit: true,
    connectivity: "Bluetooth/USB-C",
    wireless: true
  },
  product_attrs: {
    name: "Logitech MX Keys",
    category: :keyboard,
    sku: "DIT-006",
    serial_number: "KEYBOARD-SN-006",
    vendor: "Logitech",
    brand: "Logitech",
    model: "MX Keys",
    model_number: "MX-KEYS",
    status: :available,
    condition: :new_condition,
    purchase_date: 2.months.ago,
    purchase_price: 99.99,
    notes: "Wireless keyboard for shared desk"
  }
)

# Mouse
create_product_with(
  item: Mouse,
  attrs: {
    connectivity: "Bluetooth/USB Unifying",
    dpi: 4000,
    buttons: 7,
    color: "Graphite",
    rechargeable: true
  },
  product_attrs: {
    name: "Logitech MX Master 3",
    category: :mouse,
    sku: "DIT-007",
    serial_number: "MOUSE-SN-007",
    vendor: "Logitech",
    brand: "Logitech",
    model: "MX Master 3",
    model_number: "MXM3",
    status: :available,
    condition: :new_condition,
    purchase_date: 2.months.ago,
    purchase_price: 89.99,
    notes: "Wireless mouse for design team"
  }
)

puts "Created #{Product.count} products"

puts "\nSetup complete! You can now:"
puts "1. Run: rails server"
puts "2. Visit: http://localhost:3000"
puts "3. Login with admin@ditronics.com / password123"
