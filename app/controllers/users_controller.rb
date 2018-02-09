class UsersController < ApplicationController

  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :user_type, :password, :password_confirmation)
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
      redirect_to user_path(@user)
    else
      render 'new'
    end

  end

end
