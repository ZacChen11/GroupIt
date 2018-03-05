class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show, :reset_password]
  before_action :is_admin,   only: [:index, :edit, :update, :show, :reset_password]

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
    @role_map.role_id = Role.find_by(role_name: "developer").id
    if current_user && current_user.check_role("administrator")
      #when the admin create a user, the user will be activated automatically
      @user.activated = true
      if @user.save
        @role_map.save
        return redirect_to @user
      else
        return render 'new'
      end
    end

    if @user.save
      @role_map.save
      flash.notice = "Thanks for signing up"
      return redirect_to root_path
    else
      return render 'new'
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
    # check if user reset password
    if params[:user][:password].blank?
      @user.password_validation = false
    end
    if @user.update(user_params)
      # assign roles for users
      if params[:user][:roles]
       generate_role(params[:user][:roles], @user)
      end
      return redirect_to user_path(@user)
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

  private
  # Confirms the correct user or the admin user.
  def is_admin
    # When an admin tries to check all the users
    if params[:id] == nil
      if !current_user.check_role("administrator")
        flash.notice = "You don't have the previlege !"
        return redirect_to current_user
      end
    else
      @user = User.find_by(id: params[:id])
      #check a user account
      if @user
        # When the user is not the administrator
        if !current_user.check_role("administrator") && @user != current_user
          flash.notice = "You don't have the previlege !"
          return redirect_to current_user
        end
      else
        # when the user doesn't exist
        return render plain: "404 Not Found", status: 404
      end
    end
  end

  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation, :activated)
  end

  def validate_user
    if !User.find_by(id: params[:id])
      flash.notice = "User doesn't exist !"
      redirect_to current_user
    end
  end
  #
  # def is_admin
  #   if !current_user.check_role("administrator")
  #     # when the user is not administrator
  #     flash.notice = "You don't have the privilege"
  #     return redirect_to current_user
  #   end
  # end
  #
  # def correct_user
  #   @user = User.find(params[:id])
  #   if current_user != @user
  #     flash.notice = "You don't have the previlege"
  #     redirect_to current_user
  #   end
  # end

  def generate_role(roles, user)
    # parameter roles indicate an array of role ids string
    #delete roles of user
    user.role_maps.all.each do |r|
      if !roles.include?(r.role_id.to_s)
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



end
