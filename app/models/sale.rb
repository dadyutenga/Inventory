class Sale < ApplicationRecord
  belongs_to :laptop
  belongs_to :sold_by, class_name: "User"

  validates :sold_to, :sold_at, :sale_price, presence: true
  validates :sale_price, numericality: { greater_than: 0 }

  # Auto-update laptop status to sold after sale creation
  after_create :mark_laptop_as_sold

  private

  def mark_laptop_as_sold
    laptop.update(status: :sold)
  end
end
