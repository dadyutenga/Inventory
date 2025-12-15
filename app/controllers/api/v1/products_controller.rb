class Api::V1::ProductsController < Api::BaseController
  # Cache configuration
  CACHE_EXPIRY = 5.minutes

  def index
    begin
      # Sanitize and validate product type parameter
      product_type = sanitize_product_type(params[:product_type])

      # Generate cache key
      cache_key = generate_cache_key(product_type)

      # Try to get from cache first
      cached_result = Rails.cache.read(cache_key)
      if cached_result.present?
        return render_json_response(
          data: cached_result[:products],
          meta: cached_result[:meta].merge(cached: true)
        )
      end

      # Build query
      products_query = build_products_query(product_type)

      # Execute query with includes for performance
      products = products_query
                  .includes(:productable, images_attachments: :blob)
                  .where(status: :available) # Only show available products
                  .order(:name)

      # Serialize products
      serialized_products = serialize_products(products)

      # Prepare response metadata
      meta = {
        total_count: products.count,
        product_type: product_type || "all",
        cached: false,
        generated_at: Time.current.iso8601
      }

      # Cache the result
      cache_data = {
        products: serialized_products,
        meta: meta
      }
      Rails.cache.write(cache_key, cache_data, expires_in: CACHE_EXPIRY)

      render_json_response(data: serialized_products, meta: meta)

    rescue => e
      Rails.logger.error "Products API Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      render_json_response(
        data: nil,
        message: "Failed to fetch products",
        status: :internal_server_error
      )
    end
  end

  private

  def sanitize_product_type(type)
    return nil if type.blank?

    # Validate against allowed product types
    allowed_types = %w[laptop mouse keyboard server desktop_pc accessory]
    sanitized = type.to_s.strip.downcase

    return sanitized if allowed_types.include?(sanitized)

    # Log potential injection attempt
    Rails.logger.warn "Invalid product type attempted: #{type}"
    nil
  end

  def generate_cache_key(product_type)
    base_key = "api:v1:products"
    type_suffix = product_type.present? ? ":#{product_type}" : ":all"
    "#{base_key}#{type_suffix}"
  end

  def build_products_query(product_type)
    query = Product.all

    if product_type.present?
      # Use the enum method for filtering
      query = query.public_send("category_#{product_type}")
    end

    query
  end

  def serialize_products(products)
    products.map do |product|
      {
        id: product.id,
        name: product.name,
        category: product.category,
        brand: product.brand,
        model: product.model,
        sku: product.sku,
        serial_number: product.serial_number,
        condition: product.condition,
        status: product.status,
        purchase_price: product.purchase_price&.to_f,
        purchase_date: product.purchase_date&.iso8601,
        warranty_expires: product.warranty_expires&.iso8601,
        description: product.description,
        images: serialize_images(product.images),
        specifications: serialize_specifications(product.productable),
        created_at: product.created_at.iso8601,
        updated_at: product.updated_at.iso8601
      }
    end
  end

  def serialize_images(images)
    return [] unless images.attached?

    images.map do |image|
      begin
        base_data = {
          id: image.id,
          filename: image.filename.to_s,
          content_type: image.content_type,
          byte_size: image.byte_size,
          url: url_for(image)
        }

        # Only add variants for image files
        if image.content_type&.start_with?("image/")
          base_data[:variants] = {
            thumbnail: url_for(image.variant(resize_to_limit: [ 150, 150 ])),
            medium: url_for(image.variant(resize_to_limit: [ 400, 400 ])),
            large: url_for(image.variant(resize_to_limit: [ 800, 800 ]))
          }
        end

        base_data
      rescue => e
        Rails.logger.error "Image serialization error for image #{image.id}: #{e.message}"
        {
          id: image.id,
          filename: image.filename.to_s,
          content_type: image.content_type,
          byte_size: image.byte_size,
          url: url_for(image),
          error: "Variant generation failed"
        }
      end
    end
  end

  def serialize_specifications(productable)
    return {} unless productable.present?

    case productable.class.name
    when "Laptop"
      serialize_laptop_specs(productable)
    when "Mouse"
      serialize_mouse_specs(productable)
    when "Keyboard"
      serialize_keyboard_specs(productable)
    when "Server"
      serialize_server_specs(productable)
    when "DesktopPc"
      serialize_desktop_pc_specs(productable)
    else
      {}
    end
  end

  def serialize_laptop_specs(laptop)
    {
      cpu: laptop.cpu,
      ram_size: laptop.ram_size,
      ram_type: laptop.ram_type,
      storage_capacity: laptop.storage_capacity,
      storage_type: laptop.storage_type,
      gpu: laptop.gpu,
      screen_size: laptop.screen_size,
      screen_resolution: laptop.screen_resolution,
      battery_capacity: laptop.battery_capacity,
      ports: laptop.ports,
      operating_system: laptop.operating_system,
      weight: laptop.weight&.to_f
    }.compact
  end

  def serialize_mouse_specs(mouse)
    {
      mouse_type: mouse.mouse_type,
      connection_type: mouse.connection_type,
      dpi: mouse.dpi,
      buttons_count: mouse.buttons_count,
      features: mouse.features
    }.compact
  end

  def serialize_keyboard_specs(keyboard)
    {
      keyboard_type: keyboard.keyboard_type,
      connection_type: keyboard.connection_type,
      layout: keyboard.layout,
      switch_type: keyboard.switch_type,
      backlit: keyboard.backlit,
      features: keyboard.features
    }.compact
  end

  def serialize_server_specs(server)
    {
      cpu: server.cpu,
      ram_size: server.ram_size,
      storage_capacity: server.storage_capacity,
      storage_type: server.storage_type,
      raid_config: server.raid_config,
      network_ports: server.network_ports,
      power_supply: server.power_supply,
      form_factor: server.form_factor,
      operating_system: server.operating_system
    }.compact
  end

  def serialize_desktop_pc_specs(desktop_pc)
    {
      cpu: desktop_pc.cpu,
      ram_size: desktop_pc.ram_size,
      storage_capacity: desktop_pc.storage_capacity,
      storage_type: desktop_pc.storage_type,
      gpu: desktop_pc.gpu,
      motherboard: desktop_pc.motherboard,
      power_supply: desktop_pc.power_supply,
      case_type: desktop_pc.case_type,
      operating_system: desktop_pc.operating_system
    }.compact
  end
end
