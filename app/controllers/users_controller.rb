class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show, :search_report, :create_report]
  before_action :is_admin,   only: [:index, :edit, :update, :show]
  before_action :check_format, only: [:create_report]
  before_action :check_reporter, only: [:search_report, :create_report]

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

    #when the admin create a user, the user will be activated automatically
    if current_user && current_user.check_role("administrator")
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
    if @user.update(user_params)
      # assign roles for users
      if params[:user][:roles]
        params[:user][:roles].each do |r|
          # prevent to create duplicate roles
          if !@user.role_maps.exists?(role_id: r)
            @user.role_maps.create(role_id: r)
          end
        end
      end
      return redirect_to user_path(@user.id)
    else
      return render 'edit'
    end
  end

  def search_report
    if params[:tasks].present?
      records = export_task(params[:tasks])
    end
    if params[:users].present?
      records = export_user(params[:users])
    end
    respond_to do |format|
      format.html
      format.csv { send_data records.to_csv, filename: "users-#{Date.today}.csv" }
    end
  end

  def create_report
    check_filter
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
      #check if user account
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
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation)
  end

  def check_format
    if params[:start_time].present?
      if params[:end_time].present?
        if params[:start_time] > params[:end_time]
          flash.notice = "ending time should be larger than starting time, please choose again"
          render 'search_report'
        end
      else
        flash.notice = "please choose ending time"
        render 'search_report'
      end
    else
      flash.notice = "please choose starting time"
      render 'search_report'
    end
  end

  def check_reporter
    if !current_user.check_role("report manager")
      flash.notice = "You don't have the previlege"
      redirect_to current_user
    end
  end


 def export_task(a)
   records = Task.where(id: a.each{ |t| t})
   return records
  end

  def export_user(a)
    records = User.where(id: a.each{ |t| t})
    return records
  end

  def string_to_boolean(s)
    if s == "true"
      return true
    else
      return false
    end
  end

  def check_filter
    if params[:task_checked].present? && params[:user_checked].present?
      # when choose user/task
      flash.notice = "can't choose task and user at the same time, choose again"
      return render 'search_report'
    end

    if params[:task_checked].present?
      # when choose task/task status
      if params[:status_selected].present?
        @tasks = Task.created_between(params[:start_time], params[:end_time]).task_status(params[:status_selected])
      else
        # when choose task
        @tasks = Task.created_between(params[:start_time], params[:end_time])
      end
      return render 'search_report'
    end

    if params[:user_checked].present?
      if params[:user_status_selected].present?
        # when choose user/user status
        params[:user_status_selected] = string_to_boolean(params[:user_status_selected])
        @users = User.created_between(params[:start_time], params[:end_time]).user_status(params[:user_status_selected])
      else
        # when choose user
        @users = User.created_between(params[:start_time], params[:end_time])
      end
      return render 'search_report'
    end

    flash.notice = "please select task or user"
    return render 'search_report'
  end

end
