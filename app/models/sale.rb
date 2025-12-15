class Sale < ApplicationRecord
  self.primary_key = "id"

  belongs_to :product
  belongs_to :sold_by, class_name: "User"

  validates :sold_to, :sold_at, :sale_price, presence: true
  validates :sale_price, numericality: { greater_than: 0 }

  # Auto-update product status to sold after sale creation
  after_create :mark_product_as_sold

  private

  def mark_product_as_sold
    product.update(status: :sold)
  end
end
