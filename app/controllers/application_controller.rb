class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Helper method to check if current user is admin
  def admin?
    user_signed_in? && current_user.admin?
  end
  helper_method :admin?

  # Helper method to check if current user is employee
  def employee?
    user_signed_in? && current_user.employee?
  end
  helper_method :employee?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
