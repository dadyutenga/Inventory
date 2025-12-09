class ApplicationController < ActionController::Base
  # Include JWT exception handling
  include ExceptionHandler

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Skip CSRF for API requests (JWT handles authentication)
  skip_before_action :verify_authenticity_token, if: :json_request?

  # Require authentication for all actions by default
  before_action :authenticate_user

  attr_reader :current_user
  helper_method :current_user

  # Helper method to check if current user is admin
  def admin?
    current_user&.admin?
  end
  helper_method :admin?

  # Helper method to check if current user is employee
  def employee?
    current_user&.employee?
  end
  helper_method :employee?

  # Check if user is signed in
  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

  private

  # Authenticate user using JWT token from header or cookie
  def authenticate_user
    # Try to get token from Authorization header first (for API requests)
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    # Fall back to encrypted cookie (for browser/ERB view requests)
    token ||= cookies.encrypted[:auth_token]

    raise ExceptionHandler::MissingToken unless token

    decoded = JsonWebToken.decode(token)
    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound
    raise ExceptionHandler::InvalidToken
  end

  def log_activity(action_type:, record:, old_values: nil, new_values: nil)
    ActivityLogger.log(
      user: current_user,
      action_type: action_type,
      record: record,
      old_values: old_values,
      new_values: new_values,
      request: request
    )
  end

  # Check if request is JSON
  def json_request?
    request.format.json?
  end

  # Authorize admin only
  def authorize_admin!
    unless current_user&.admin?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Only admins can perform this action." }
        format.json { render json: { error: "Only admins can perform this action." }, status: :forbidden }
      end
    end
  end
end
