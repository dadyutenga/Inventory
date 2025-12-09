class ProcessLaptopImagesJob < ApplicationJob
  queue_as :default

  def perform(laptop_id)
    laptop = Laptop.find(laptop_id)

    laptop.product&.images&.each do |image|
      # Generate thumbnail variant
      image.variant(resize_to_limit: [ 300, 200 ]).processed

      # Generate medium variant
      image.variant(resize_to_limit: [ 800, 600 ]).processed

      # Generate large variant
      image.variant(resize_to_limit: [ 1200, 900 ]).processed
    end

    Rails.logger.info "Processed #{laptop.product&.images&.count || 0} images for laptop #{laptop.id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Laptop #{laptop_id} not found: #{e.message}"
  rescue => e
    Rails.logger.error "Error processing images for laptop #{laptop_id}: #{e.message}"
    raise e
  end
end
