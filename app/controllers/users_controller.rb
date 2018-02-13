class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def logged_in_user
    unless logged_in?
      redirect_to login_path
    end
  end

  # Confirms the correct user or the admin user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to login_path unless @user == current_user || current_user.user_type
  end

  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :user_type, :password, :password_confirmation)
  end

  def index
    @users = User.all
    @user = User.find(params[:user])
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
      if params[:admin] == nil
        log_in(@user)
        redirect_to @user
      else
        redirect_to users_path(:user => params[:admin])
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
      redirect_to user_path(@user.id, :admin => params[:admin])
    else
      render 'edit'
    end
  end


end
