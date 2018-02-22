class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show]
  before_action :correct_user,   only: [:index, :edit, :update, :show]


  private def logged_in_user
    unless logged_in?
      flash.notice = "Please Log In"
      redirect_to root_path
    end
  end

  # Confirms the correct user or the admin user.
  private def correct_user
    # When an admin tries to check all the users
    if params[:id] == nil
      unless current_user.roles.exists?(role_name: "administrator")
        flash.notice = "You are not the right user !"
        redirect_to root_path
      end
    else
      @user = User.find_by(id: params[:id])
      #check if user exists in database
      if @user
        # When the user is not the administrator
        unless current_user.roles.exists?(role_name: "administrator")
          unless @user == current_user
            flash.notice = "Your are not the right user !"
            redirect_to root_path
          end
        end
      else
        flash.notice = "User doesn't exist !"
        redirect_to current_user
      end
    end
  end

  private def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation)
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
    # set new user as developer
    @role_map = @user.role_maps.new
    @role_map.role_id = Role.find_by(role_name: "developer").role_type
    #when the admin create a user, the user will be activated automatically
    if current_user && current_user.roles.exists?(role_name: "administrator")
      @user.activated = true
      if @user.save
        @role_map.save
        redirect_to @user
      else
        render 'new'
      end
    else
      if @user.save
        @role_map.save
        flash.notice = "Thanks for signing up"
        redirect_to root_path
      else
        render 'new'
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def update



    @user = User.find(params[:id])
    if @user.update(user_params)
      # assign roles for users
      if params[:user][:roles]
        params[:user][:roles].each do |r|
          @user.role_maps.create(role_id: r)
        end
      end
      redirect_to user_path(@user.id)
    else
      render 'edit'
    end
  end


end
