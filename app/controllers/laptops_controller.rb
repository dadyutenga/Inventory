class LaptopsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_laptop, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_admin!, only: [ :destroy ]

  def index
    @laptops = Laptop.includes(:allocated_to, images_attachments: :blob)
                    .search(params[:search])
                    .by_brand(params[:brand])
                    .by_status(params[:status])
                    .order(created_at: :desc)

    # Cache the brands list for filter dropdown
    @brands = Rails.cache.fetch("laptop_brands", expires_in: 1.hour) do
      Laptop.distinct.pluck(:brand).compact.sort
    end
  end

  def show
  end

  def new
    @laptop = Laptop.new
  end

  def create
    @laptop = Laptop.new(laptop_params)

    if @laptop.save
      # Enqueue background job for image processing
      ProcessLaptopImagesJob.perform_later(@laptop.id) if @laptop.images.attached?

      redirect_to @laptop, notice: "Laptop was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @laptop.update(laptop_params)
      # Enqueue background job for newly added images
      ProcessLaptopImagesJob.perform_later(@laptop.id) if @laptop.images.attached?

      redirect_to @laptop, notice: "Laptop was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @laptop.destroy
    redirect_to laptops_url, notice: "Laptop was successfully deleted."
  end

  def remove_image
    @laptop = Laptop.find(params[:id])
    image = @laptop.images.find(params[:image_id])
    image.purge
    redirect_to edit_laptop_path(@laptop), notice: "Image removed successfully."
  end

  private

  def set_laptop
    @laptop = Laptop.find(params[:id])
  end

  def laptop_params
    params.require(:laptop).permit(
      :sku, :vendor, :brand, :model, :model_number, :serial_number,
      :purchase_date, :purchase_price, :condition,
      :cpu, :cpu_generation, :gpu, :ram_size, :ram_type,
      :storage_capacity, :storage_type, :screen_size, :screen_resolution,
      :display_type, :keyboard_type, :keyboard_backlight,
      :battery_capacity, :webcam, :microphone, :wifi_type,
      :bluetooth_version, :ports, :weight,
      :operating_system, :license_key, :status,
      :allocated_to_id, :last_service_date, :next_service_due, :notes,
      images: []
    )
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to laptops_path, alert: "Only admins can perform this action."
    end
  end
end
