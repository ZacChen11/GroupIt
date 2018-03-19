class AdministratorsController < ApplicationController
  before_action :is_admin_before_action
  before_action :load_user_before_action, only: [:show_user, :edit_user, :update_user, :destroy_user]

  def index_user
    @users = User.all
    @user = User.find(current_user.id)
  end

  def show_user
  end

  def new_user
    @user = User.new
  end

  def create_user
    @user = User.create(user_params)
    if @user.save
      # assign roles for a new user
      @user.update_role(params[:user][:roles])
      return redirect_to @user
    else
      return render 'new_user'
    end
  end

  def edit_user
  end

  def update_user
    # check if user reset password, if doesn't, skip the password validation
    if params[:user][:password].blank?
      @user.password_validation = false
    end
    if @user.update(user_params)
      # update roles for users
      @user.update_role(params[:user][:roles])
      return redirect_to @user
    else
      return render 'edit_user'
    end
  end

  def destroy_user
    # skip password validation
    @user.password_validation = false
    @user.update(activated: false)
    redirect_to @user
  end

  def index_project
    @projects = Project.all.validated_projects
    if params[:project_filter_selected] == "all_projects"
      @projects = Project.all.validated_projects
    elsif params[:project_filter_selected] == "assigned_projects"
      @projects = current_user.assigned_projects.validated_projects
    elsif params[:project_filter_selected] == "create_projects"
      @projects = current_user.projects.validated_projects
    elsif params.has_key?("project_filter_selected") && params[:project_filter_selected].blank?
      flash.notice = "please choose a scope"
      return redirect_to administrators_index_project_path
    end
  end

  def index_task
    # return the tasks by its relevant: confirmed > pending > create > others
    @tasks = current_user.return_admin_tasks_by_relevant
    if params[:task_filter_selected] == "all_tasks"
      @tasks = current_user.return_admin_tasks_by_relevant
    elsif params[:task_filter_selected] == "confirmed_tasks"
      @tasks = current_user.assigned_and_confirmed_tasks
    elsif params[:task_filter_selected] == "create_tasks"
      @tasks = current_user.tasks.validated_tasks
    elsif params[:task_filter_selected] == "pending_tasks"
      @tasks = current_user.assigned_and_pending_tasks
    elsif params[:task_filter_selected] == "feature"
      @tasks = current_user.return_taks_of_type(current_user.return_admin_tasks_by_relevant, "Feature")
    elsif params[:task_filter_selected] == "bug"
      @tasks = current_user.return_taks_of_type(current_user.return_admin_tasks_by_relevant, "Bug")
    elsif params[:task_filter_selected] == "improvement"
      @tasks = current_user.return_taks_of_type(current_user.return_admin_tasks_by_relevant, "Improvement")
    elsif params.has_key?("task_filter_selected") && params[:task_filter_selected].blank?
      flash.notice = "please choose a scope"
      return redirect_to administrators_index_task_path
    end
  end

  private
  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation, :activated)
  end

  def load_user_before_action
    @user = User.find_by(id: params[:id])
    if @user.blank?
      flash.notice = "User doesn't exist !"
      redirect_to root_path
    end
  end

end
