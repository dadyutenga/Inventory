class AuthController < ApplicationController
  skip_before_action :authenticate_user, only: [ :login_page, :login ]

  # GET /login
  def login_page
    render :login
  end

  # POST /login
  def login
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)

      respond_to do |format|
        format.json { render json: { token: token, user: user_response(user) }, status: :ok }
        format.html do
          # Store JWT in httpOnly cookie (secure, stateless)
          cookies.encrypted[:auth_token] = {
            value: token,
            httponly: true,
            secure: Rails.env.production?,
            same_site: :lax
          }
          redirect_to root_path, notice: "Logged in successfully"
        end
      end
    else
      respond_to do |format|
        format.json { render json: { error: "Invalid email or password" }, status: :unauthorized }
        format.html do
          flash[:alert] = "Invalid email or password"
          redirect_to login_path
        end
      end
    end
  end

  # DELETE /logout
  def logout
    # Get the token before deleting it
    token = request.headers["Authorization"]&.split(" ")&.last || cookies.encrypted[:auth_token]

    # Blacklist the token if it exists
    if token
      begin
        decoded = JWT.decode(token, JsonWebToken::SECRET_KEY, true, { algorithm: "HS256" })
        expires_at = Time.at(decoded[0]["exp"])
        BlacklistedToken.blacklist(token, expires_at)
      rescue JWT::DecodeError, JWT::ExpiredSignature
        # Token is invalid or expired, no need to blacklist
      end
    end

    respond_to do |format|
      format.json { render json: { message: "Logged out successfully" }, status: :ok }
      format.html do
        cookies.delete(:auth_token)
        redirect_to login_path, notice: "Logged out successfully"
      end
    end
  end

  private

  def user_response(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role
    }
  end
end
