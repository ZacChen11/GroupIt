class AdministratorsController < ApplicationController
  before_action :is_admin_before_action
  before_action :load_user_before_action, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
    @user = User.find(current_user.id)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.save
      # assign roles for a new user
      if params[:user][:roles]
        update_role(params[:user][:roles], @user)
      end
      return redirect_to @user
    else
      return render 'new'
    end
  end

  def edit
  end

  def update
    # check if user reset password
    if params[:user][:password].blank?
      @user.password_validation = false
    end
    if @user.update(user_params)
      # update roles for users
      if params[:user][:roles]
        update_role(params[:user][:roles], @user)
      end
      return redirect_to @user
    else
      return render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation, :activated)
  end

  def update_role(roles, user)
    # parameter roles indicate an array of role ids string
    #delete roles of user
    user.role_maps.all.each do |r|
      if roles.exclude?(r.role_id.to_s)
        r.destroy
      end
    end
    #add new role to user
    roles.each do |r|
      if !user.role_maps.exists?(role_id: r)
        user.role_maps.create(role_id: r)
      end
    end
  end

  def load_user_before_action
    @user = User.find_by(id: params[:id])
    if @user.blank?
      flash.notice = "User doesn't exist !"
      redirect_to root_path
    end
  end


end
