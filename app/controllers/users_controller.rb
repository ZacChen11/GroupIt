class UsersController < ApplicationController
  skip_before_action :verify_user_logged_in_before_action, only: [:new, :create]
  before_action :is_the_correct_user_before_action, only: [:reset_password]
  before_action :verify_user_already_logged_in_before_action, only: [:new]
  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.save
      # set new user as developer
      @user.role_maps.create(role_id: Role.find_by(role_name: "developer").id)
      flash.notice = "Thanks for signing up"
      return redirect_to login_path
    else
      return render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    # check if user reset password
    if params[:user][:password].blank?
      @user.password_validation = false
    end
    if @user.update(user_params)
      return redirect_to root_path
    end
    if !params[:user].has_key?("password")
      return render 'edit'
    else
       return render 'reset_password'
    end
  end

  def reset_password
    @user = User.find(params[:id])
  end

  def profile
    @user = User.find(current_user.id)
  end

  private
  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation, :activated)
  end

  def is_the_correct_user_before_action
    # when the current user tries to do something to other users account
    if !(current_user.has_role?("administrator") || current_user == @user = User.find(params[:id]))
      flash.notice = "You don't have the privilege"
      return redirect_to root_path
    end
  end




end
