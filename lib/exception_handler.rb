module ExceptionHandler
  extend ActiveSupport::Concern

  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end
  class InvalidToken < StandardError; end
  class ExpiredSignature < StandardError; end
  class DecodeError < StandardError; end

  included do
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
    rescue_from ExceptionHandler::MissingToken, with: :unauthorized_request
    rescue_from ExceptionHandler::InvalidToken, with: :unauthorized_request
    rescue_from ExceptionHandler::ExpiredSignature, with: :token_expired
    rescue_from ExceptionHandler::DecodeError, with: :invalid_token
  end

  private

  def unauthorized_request(exception)
    respond_to do |format|
      format.json { render json: { error: exception.message }, status: :unauthorized }
      format.html { redirect_to login_path, alert: "Please login to continue" }
    end
  end

  def token_expired(exception)
    respond_to do |format|
      format.json { render json: { error: "Token has expired. Please login again." }, status: :unauthorized }
      format.html { redirect_to login_path, alert: "Your session has expired. Please login again." }
    end
  end

  def invalid_token(exception)
    respond_to do |format|
      format.json { render json: { error: "Invalid token. Please login again." }, status: :unauthorized }
      format.html { redirect_to login_path, alert: "Invalid session. Please login again." }
    end
  end
end
