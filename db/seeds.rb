# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

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

# Create sample laptops
laptops_data = [
  {
    sku: "DIT-001",
    vendor: "Tech Distributors Inc",
    brand: "Dell",
    model: "Latitude 5420",
    model_number: "LAT-5420-I7",
    serial_number: "DELL-SN-001",
    purchase_date: 6.months.ago,
    purchase_price: 1200.00,
    condition: :new_condition,
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
    license_key: "WIN11-XXXXX-XXXXX-XXXXX",
    status: :active,
    allocated_to: employee,
    notes: "Excellent business laptop for office work"
  },
  {
    sku: "DIT-002",
    vendor: "HP Enterprise",
    brand: "HP",
    model: "EliteBook 840 G8",
    model_number: "EB840-G8",
    serial_number: "HP-SN-002",
    purchase_date: 4.months.ago,
    purchase_price: 1450.00,
    condition: :new_condition,
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
    license_key: "WIN11-YYYYY-YYYYY-YYYYY",
    status: :active,
    notes: "High-performance laptop for developers"
  },
  {
    sku: "DIT-003",
    vendor: "Lenovo Direct",
    brand: "Lenovo",
    model: "ThinkPad X1 Carbon Gen 9",
    model_number: "X1C-G9",
    serial_number: "LENOVO-SN-003",
    purchase_date: 3.months.ago,
    purchase_price: 1800.00,
    condition: :refurbished,
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
    license_key: "WIN11-ZZZZZ-ZZZZZ-ZZZZZ",
    status: :in_repair,
    last_service_date: 1.week.ago,
    next_service_due: 2.weeks.from_now,
    notes: "Ultralight premium laptop, currently in repair for keyboard replacement"
  }
]

laptops_data.each do |laptop_data|
  Laptop.find_or_create_by!(serial_number: laptop_data[:serial_number]) do |laptop|
    laptop.assign_attributes(laptop_data)
  end
end

puts "Created #{Laptop.count} sample laptops"

puts "\nSetup complete! You can now:"
puts "1. Run: rails server"
puts "2. Visit: http://localhost:3000"
puts "3. Login with admin@ditronics.com / password123"
