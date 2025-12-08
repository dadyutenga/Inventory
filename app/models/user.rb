class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { employee: 0, admin: 1 }, default: :employee

  has_many :laptops_allocated, class_name: "Laptop", foreign_key: "allocated_to_id", dependent: :nullify
  has_many :sales, foreign_key: "sold_by_id", dependent: :restrict_with_error

  validates :name, presence: true
end
