class ProductsController < ApplicationController
  before_action :authenticate_user
  before_action :set_product, only: [ :show, :edit, :update, :destroy, :remove_image ]
  before_action :authorize_admin!, only: [ :destroy ]
  before_action :set_category, only: [ :new, :create, :edit, :update ]

  def index
    @products = Product.includes(:productable, :allocated_to, images_attachments: :blob)
                       .search(params[:search])
                       .by_category(params[:category])
                       .by_status(params[:status])
                       .order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new(category: @category)
    @product.productable = build_productable(@category)
  end

  def create
    @product = Product.new(product_params.except(:category))
    @product.category = product_params[:category]
    @product.productable = build_productable(@product.category, equipment_params(@product.category))

    if @product.save
      ProcessProductImagesJob.perform_later(@product.id) if @product.images.attached?
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product.productable ||= build_productable(@product.category)
  end

  def update
    equipment_attrs = equipment_params(@product.category)

    success = ActiveRecord::Base.transaction do
      @product.productable.update!(equipment_attrs) if equipment_attrs.present?
      @product.update(product_params.except(:category))
    end

    if success
      ProcessProductImagesJob.perform_later(@product.id) if @product.images.attached?
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: "Product was successfully deleted."
  end

  def remove_image
    image = @product.images.find(params[:image_id])
    image.purge
    redirect_to edit_product_path(@product), notice: "Image removed successfully."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_category
    @category = params[:category] || params.dig(:product, :category) || @product&.category || "laptop"
  end

  def product_params
    params.require(:product).permit(
      :name, :category, :sku, :serial_number, :vendor, :brand, :model, :model_number,
      :location, :status, :condition, :purchase_date, :purchase_price,
      :last_service_date, :next_service_due, :allocated_to_id, :notes,
      images: []
    )
  end

  def equipment_params(category)
    key = equipment_param_key(category)
    return {} unless key && params[:product].present?

    params[:product].fetch(key, {}).permit(*equipment_fields(category))
  end

  def equipment_param_key(category)
    {
      "laptop" => :laptop_attributes,
      "mouse" => :mouse_attributes,
      "keyboard" => :keyboard_attributes,
      "server" => :server_attributes,
      "desktop_pc" => :desktop_pc_attributes,
      "accessory" => :accessory_attributes
    }[category.to_s]
  end

  def equipment_fields(category)
    case category.to_s
    when "laptop"
      [
        :cpu, :cpu_generation, :gpu, :ram_size, :ram_type,
        :storage_capacity, :storage_type, :screen_size, :screen_resolution,
        :display_type, :keyboard_type, :keyboard_backlight,
        :battery_capacity, :webcam, :microphone, :wifi_type,
        :bluetooth_version, :ports, :weight, :operating_system, :license_key
      ]
    when "mouse"
      [ :connectivity, :dpi, :buttons, :color, :rechargeable ]
    when "keyboard"
      [ :layout, :switch_type, :backlit, :connectivity, :wireless ]
    when "server"
      [ :cpu_model, :cpu_count, :ram_size, :storage_capacity, :storage_type, :raid_level, :operating_system, :rack_units ]
    when "desktop_pc"
      [ :cpu, :ram_size, :storage_capacity, :storage_type, :gpu, :form_factor ]
    else
      []
    end
  end

  def build_productable(category, attrs = {})
    case category.to_s
    when "laptop"
      Laptop.new(attrs)
    when "mouse"
      Mouse.new(attrs)
    when "keyboard"
      Keyboard.new(attrs)
    when "server"
      Server.new(attrs)
    when "desktop_pc"
      DesktopPc.new(attrs)
    else
      Laptop.new(attrs)
    end
  end

  def authorize_admin!
    return if current_user.admin?

    redirect_to products_path, alert: "Only admins can perform this action."
  end
end
