class ProcessProductImagesJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find(product_id)

    product.images.each do |image|
      image.variant(resize_to_limit: [ 300, 200 ]).processed
      image.variant(resize_to_limit: [ 800, 600 ]).processed
      image.variant(resize_to_limit: [ 1200, 900 ]).processed
    end

    Rails.logger.info "Processed #{product.images.count} images for product #{product.id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Product #{product_id} not found: #{e.message}"
  rescue => e
    Rails.logger.error "Error processing images for product #{product_id}: #{e.message}"
    raise e
  end
end
