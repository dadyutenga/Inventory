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
          # For browser requests, store token in session for compatibility with ERB views
          session[:auth_token] = token
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
    respond_to do |format|
      format.json { render json: { message: "Logged out successfully" }, status: :ok }
      format.html do
        session.delete(:auth_token)
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
