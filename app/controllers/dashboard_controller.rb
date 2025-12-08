class DashboardController < ApplicationController
  before_action :authenticate_user

  def index
    # Cache dashboard statistics for 15 minutes
    @stats = Rails.cache.fetch("dashboard_stats", expires_in: 15.minutes) do
      {
        total_laptops: Laptop.count,
        active_laptops: Laptop.status_active.count,
        sold_laptops: Laptop.status_sold.count,
        in_repair_laptops: Laptop.status_in_repair.count,
        retired_laptops: Laptop.status_retired.count,
        total_sales: Sale.count,
        total_revenue: Sale.sum(:sale_price),
        avg_sale_price: Sale.average(:sale_price)
      }
    end

    # Recent sales (not cached for real-time updates)
    @recent_sales = Sale.includes(:laptop, :sold_by).order(sold_at: :desc).limit(10)

    # Recent laptops
    @recent_laptops = Laptop.includes(:allocated_to).order(created_at: :desc).limit(8)

    # Low stock alerts (laptops needing service)
    @service_due = Laptop.where("next_service_due <= ?", 30.days.from_now)
                        .where("next_service_due >= ?", Date.current)
                        .order(:next_service_due)
                        .limit(5)
  end

  def clear_cache
    Rails.cache.delete("dashboard_stats")
    Rails.cache.delete("laptop_brands")
    redirect_to dashboard_index_path, notice: "Cache cleared successfully."
  end
end
