class Api::BaseController < ActionController::Base
  # Skip CSRF protection for API requests
  skip_before_action :verify_authenticity_token

  # Rate limiting using memory store (can be switched to Redis for production)
  before_action :check_rate_limit

  # Standard error handling
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  private

  def check_rate_limit
    client_ip = request.remote_ip
    cache_key = "api_rate_limit:#{client_ip}"

    # Get current request count for this IP
    current_count = Rails.cache.read(cache_key) || 0

    # Allow 100 requests per minute per IP
    rate_limit = 100
    window_size = 1.minute

    if current_count >= rate_limit
      render json: {
        error: "Rate limit exceeded",
        message: "Too many requests. Limit: #{rate_limit} requests per minute",
        retry_after: 60
      }, status: :too_many_requests
      return
    end

    # Increment counter
    Rails.cache.write(cache_key, current_count + 1, expires_in: window_size)
  end

  def handle_standard_error(exception)
    Rails.logger.error "API Error: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if exception.backtrace

    render json: {
      error: "Internal server error",
      message: "An unexpected error occurred"
    }, status: :internal_server_error
  end

  def handle_not_found(exception)
    render json: {
      error: "Not found",
      message: exception.message
    }, status: :not_found
  end

  def render_json_response(data: nil, message: nil, status: :ok, meta: {})
    response_hash = {
      success: status.to_s.start_with?("2"),
      data: data,
      meta: meta
    }

    response_hash[:message] = message if message.present?

    render json: response_hash, status: status
  end
end
