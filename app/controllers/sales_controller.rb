class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sale, only: [ :show ]

  def index
    @sales = Sale.includes(:laptop, :sold_by).order(sold_at: :desc)
  end

  def new
    @sale = Sale.new
    @laptops = Laptop.where.not(status: :sold).order(:brand, :model)
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.sold_by = current_user
    @sale.sold_at = Time.current if @sale.sold_at.blank?

    if @sale.save
      redirect_to @sale, notice: "Sale was successfully recorded."
    else
      @laptops = Laptop.where.not(status: :sold).order(:brand, :model)
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(:laptop_id, :sold_to, :sold_at, :sale_price, :invoice_ref)
  end
end
