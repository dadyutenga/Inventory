class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [ :register_page, :create ]

  # GET /register
  def register_page
    render :register
  end

  # POST /register
  def create
    user = User.new(user_params)
    user.role ||= :employee # Default role

    if user.save
      token = JsonWebToken.encode(user_id: user.id)

      respond_to do |format|
        format.json { render json: { token: token, user: user_response(user) }, status: :created }
        format.html do
          session[:auth_token] = token
          redirect_to root_path, notice: "Account created successfully"
        end
      end
    else
      respond_to do |format|
        format.json { render json: { errors: user.errors.full_messages }, status: :unprocessable_entity }
        format.html do
          flash[:alert] = user.errors.full_messages.join(", ")
          redirect_to register_path
        end
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def user_response(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role
    }
  end
end
