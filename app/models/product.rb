class Product < ApplicationRecord
  self.primary_key = "id"

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
  validates :purchase_price, numericality: { greater_than_or_equal_to: 0, less_than: 10_000_000_000 }, allow_nil: true
  validate :purchase_price_within_range

  # Cache invalidation callbacks
  after_save :invalidate_api_cache
  after_destroy :invalidate_api_cache
  after_touch :invalidate_api_cache

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

  private

  def purchase_price_within_range
    return if purchase_price.blank?
    value = BigDecimal(purchase_price.to_s) rescue nil
    return errors.add(:purchase_price, "is not a valid number") unless value

    if value.abs >= 10_000_000_000
      errors.add(:purchase_price, "must be less than 10,000,000,000")
    end
  end

  def invalidate_api_cache
    # Skip cache invalidation if caching is not available or configured
    return unless Rails.cache.respond_to?(:delete) && caching_enabled?

    # Define all possible cache keys to invalidate
    cache_keys = [
      "api:v1:products:all",
      "api:v1:products:laptop",
      "api:v1:products:mouse",
      "api:v1:products:keyboard",
      "api:v1:products:server",
      "api:v1:products:desktop_pc",
      "api:v1:products:accessory"
    ]

    # Delete each cache key individually (SolidCache compatible)
    cache_keys.each do |key|
      Rails.cache.delete(key)
    end

    # Log cache invalidation for debugging
    Rails.logger.info "API cache invalidated for product: #{id}"
  rescue ActiveRecord::StatementInvalid, PG::UndefinedTable => e
    # Handle cases where cache tables don't exist yet (during setup/seeding)
    Rails.logger.warn "Cache invalidation skipped - cache tables not available: #{e.message}"
  rescue => e
    Rails.logger.error "Failed to invalidate API cache: #{e.message}"
  end

  private

  def caching_enabled?
    # Check if caching is enabled and cache store is available
    Rails.application.config.cache_store.present? &&
    Rails.cache.class.name != "ActiveSupport::Cache::NullStore"
  rescue
    false
  end
end
