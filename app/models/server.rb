class Server < ApplicationRecord
  self.primary_key = "id"

  has_one :product, as: :productable, dependent: :destroy, inverse_of: :productable

  validates :cpu_model, :ram_size, :storage_capacity, presence: true, allow_blank: false

  delegate :name, :display_name, to: :product, allow_nil: true
end
