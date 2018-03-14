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

  def index_task
    @tasks = current_user.assigned_and_confirmed_tasks + current_user.assigned_and_pending_tasks + current_user.tasks + current_user.have_accessed_tasks
    if params[:task_filter_selected] == "all_tasks"
      @tasks = current_user.assigned_and_confirmed_tasks + current_user.assigned_and_pending_tasks + current_user.tasks + current_user.have_accessed_tasks
    elsif params[:task_filter_selected] == "assigned_and_confirmed_tasks"
      @tasks = current_user.assigned_and_confirmed_tasks
    elsif params[:task_filter_selected] == "create_tasks"
      @tasks = current_user.tasks
    elsif params[:task_filter_selected] == "assigned_and_pending_tasks"
      @tasks = current_user.assigned_and_pending_tasks
    elsif params[:task_filter_selected] == "other_accessed_tasks"
      @tasks = current_user.have_accessed_tasks
    elsif params.has_key?("task_filter_selected") && params[:task_filter_selected].blank?
      flash.notice = "please choose a scope"
      return redirect_to index_task_user_path(current_user)
    end
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
