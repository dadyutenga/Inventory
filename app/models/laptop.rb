class Laptop < ApplicationRecord
  belongs_to :allocated_to, class_name: "User", optional: true
  has_one :sale, dependent: :restrict_with_error
  has_many_attached :images

  enum :condition, { new_condition: 0, used: 1, refurbished: 2 }, prefix: true
  enum :status, { active: 0, in_repair: 1, retired: 2, sold: 3 }, prefix: true

  validates :sku, presence: true, uniqueness: true
  validates :serial_number, presence: true, uniqueness: true
  validates :brand, :model, presence: true
  validates :purchase_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes for filtering
  scope :available, -> { where(status: :active) }
  scope :by_brand, ->(brand) { where(brand: brand) if brand.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :search, ->(query) {
    where("brand ILIKE ? OR model ILIKE ? OR sku ILIKE ? OR serial_number ILIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%") if query.present?
  }

  # Broadcast new laptop added via Action Cable
  after_create_commit -> { broadcast_new_laptop }

  def display_name
    "#{brand} #{model} (#{serial_number})"
  end

  def main_image
    images.first
  end

  private

  def broadcast_new_laptop
    broadcast_append_to "laptops",
                        partial: "laptops/laptop_notification",
                        locals: { laptop: self },
                        target: "laptop_notifications"
  end
end
