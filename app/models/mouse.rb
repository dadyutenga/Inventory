class Mouse < ApplicationRecord
  has_one :product, as: :productable, dependent: :destroy, inverse_of: :productable

  validates :connectivity, :dpi, presence: true, allow_blank: false

  delegate :name, :display_name, to: :product, allow_nil: true
end
