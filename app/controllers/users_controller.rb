class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :show]
  before_action :correct_user,   only: [:index, :edit, :update, :show]
  before_action :check_format, only: [:create_report]


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
        render plain: "404 Not Found", status: 404
        # flash.notice = "User doesn't exist !"
        # redirect_to current_user
      end
    end
  end

  private def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation)
  end

  private def check_format
    unless params[:start_time].present?
      flash.notice = "please choose starting time"
      render 'search_report'
    else
      unless params[:end_time].present?
        flash.notice = "please choose ending time"
        render 'search_report'
      else
        unless params[:start_time] < params[:end_time]
          flash.notice = "ending time should be larger than starting time, please choose again"
          render 'search_report'

        end
      end
    end
  end

  def index
    @users = User.all
    @user = User.find(current_user.id)
    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv, filename: "users-#{Date.today}.csv" }
    end
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
          # prevent to create duplicate roles
          unless @user.role_maps.exists?(role_id: r)
            @user.role_maps.create(role_id: r)
          end
        end
      end
      redirect_to user_path(@user.id)
    else
      render 'edit'
    end
  end

  def search_report
    @tasks = Task.all
    @users = User.all
  end

  private def check_filter
            if params[:task_checked].present? && params[:user_checked].present?
              @users = User.created_between(params[:start_time], params[:end_time])
              # when choose task/user/task status
              if params[:status_selected].present?
                    @tasks = Task.created_between(params[:start_time], params[:end_time]).task_status(params[:status_selected])
                    render 'search_report' and return
              else
                # when choose task/user
                @tasks = Task.created_between(params[:start_time], params[:end_time])
                render 'search_report' and return
              end
            elsif params[:task_checked].present? && !params[:user_checked].present?
              # when choose task/task status
              if params[:status_selected].present?
                @tasks = Task.created_between(params[:start_time], params[:end_time]).task_status(params[:status_selected])
                render 'search_report' and return
              else
                # when choose task
                @tasks = Task.created_between(params[:start_time], params[:end_time])
                render 'search_report' and return
              end
              # when choose user
            elsif !params[:task_checked].present? && params[:user_checked].present?
              @users = User.created_between(params[:start_time], params[:end_time])
              render 'search_report' and return
            else
              # when choose task status
              if params[:status_selected].present?
                @tasks = Task.created_between(params[:start_time], params[:end_time]).task_status(params[:status_selected])
                render 'search_report' and return
              else
                # when nothing
                @tasks = Task.created_between(params[:start_time], params[:end_time])
                render 'search_report' and return
              end
            end
  end

  def create_report
    check_filter
  end

end
