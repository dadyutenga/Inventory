class UsersController < ApplicationController
  before_action :authorize_admin!
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  # GET /users
  def index
    @users = User.all.order(created_at: :desc)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.role ||= :employee # Default role

    if @user.save
      respond_to do |format|
        format.json { render json: { user: user_response(@user) }, status: :created }
        format.html { redirect_to users_path, notice: "User created successfully" }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
        format.html do
          flash.now[:alert] = @user.errors.full_messages.join(", ")
          render :new, status: :unprocessable_entity
        end
      end
    end
  end

  # GET /users/:id/edit
  def edit
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      respond_to do |format|
        format.json { render json: { user: user_response(@user) }, status: :ok }
        format.html { redirect_to users_path, notice: "User updated successfully" }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
        format.html do
          flash.now[:alert] = @user.errors.full_messages.join(", ")
          render :edit, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /users/:id
  def destroy
    if @user == current_user
      respond_to do |format|
        format.json { render json: { error: "Cannot delete your own user account" }, status: :unprocessable_entity }
        format.html do
          redirect_to users_path, alert: "Cannot delete your own user account"
        end
      end
    else
      @user.destroy
      respond_to do |format|
        format.json { render json: { message: "User deleted successfully" }, status: :ok }
        format.html { redirect_to users_path, notice: "User deleted successfully" }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

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
