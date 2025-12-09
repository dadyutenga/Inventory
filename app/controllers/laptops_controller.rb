class LaptopsController < ApplicationController
  def index
    redirect_to products_path
  end

  def show
    laptop = Laptop.find(params[:id])
    redirect_to product_path(laptop.product)
  end

  def new
    redirect_to new_product_path(category: :laptop)
  end

  def edit
    laptop = Laptop.find(params[:id])
    redirect_to edit_product_path(laptop.product)
  end

  def create
    redirect_to new_product_path(category: :laptop)
  end

  def update
    laptop = Laptop.find(params[:id])
    redirect_to edit_product_path(laptop.product)
  end

  def destroy
    laptop = Laptop.find(params[:id])
    redirect_to product_path(laptop.product)
  end
end
