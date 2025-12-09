class Product < ApplicationRecord
  belongs_to :productable, polymorphic: true
  belongs_to :allocated_to, class_name: "User", optional: true

  has_many_attached :images
  has_one :sale, dependent: :restrict_with_error

  enum :category, {
    laptop: 0,
    mouse: 1,
    keyboard: 2,
    server: 3,
    desktop_pc: 4,
    accessory: 5
  }, prefix: true

  enum :status, {
    available: 0,
    allocated: 1,
    in_service: 2,
    retired: 3,
    sold: 4
  }, prefix: true

  enum :condition, { new_condition: 0, used: 1, refurbished: 2 }, prefix: true

  validates :name, :category, :sku, :serial_number, presence: true
  validates :sku, :serial_number, uniqueness: true
  validates :purchase_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :search, ->(query) {
    if query.present?
      pattern = "%#{query}%"
      where("name ILIKE :pattern OR sku ILIKE :pattern OR serial_number ILIKE :pattern OR brand ILIKE :pattern OR model ILIKE :pattern", pattern: pattern)
    else
      all
    end
  }

  def display_name
    name.presence || sku.presence || serial_number
  end

  def productable_label
    productable&.class&.name || "Item"
  end
end
