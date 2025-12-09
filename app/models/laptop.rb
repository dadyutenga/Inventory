class Laptop < ApplicationRecord
  has_one :product, as: :productable, dependent: :destroy, inverse_of: :productable

  # Hardware-specific validations
  validates :cpu, :ram_size, :storage_capacity, presence: true, allow_blank: false, if: -> { product&.category_laptop? }

  delegate :name, :display_name, :status, :condition, :serial_number, :sku, to: :product, allow_nil: true

  private
end
