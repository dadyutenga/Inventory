class User < ApplicationRecord
  # Use bcrypt for password hashing instead of Devise
  has_secure_password

  enum :role, { employee: 0, admin: 1 }, default: :employee

  has_many :products_allocated, class_name: "Product", foreign_key: "allocated_to_id", dependent: :nullify
  has_many :sales, foreign_key: "sold_by_id", dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Normalize email before save
  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
