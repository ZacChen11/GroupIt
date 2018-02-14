class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show]
  before_action :correct_user,   only: [:index, :edit, :update, :show]

  def logged_in_user
    unless logged_in?
      redirect_to root_path
    end
  end

  # Confirms the correct user or the admin user.
  def correct_user
    # When an admin tries to check all the users
    if params[:id] == nil
      redirect_to root_path unless current_user.user_type
    else
      @user = User.find(params[:id])
      # When the user is not the administrator
      if !current_user.user_type
        redirect_to root_path unless @user == current_user
      end
    end

  end

  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :user_type, :password, :password_confirmation)
  end

  def index
    @users = User.all
    @user = User.find(current_user.id)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.save
      if current_user != nil && current_user.user_type
        redirect_to users_path
      else
        log_in(@user)
        redirect_to @user
      end
    else
        render 'new'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path(:user =>params[:admin])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user.id)
    else
      render 'edit'
    end
  end


end
