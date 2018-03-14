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
      update_role(params[:user][:roles], @user)
      return redirect_to @user
    else
      return render 'new_user'
    end
  end

  def edit_user
  end

  def update_user

    # check if user reset password
    if params[:user][:password].blank?
      @user.password_validation = false
    end
    if @user.update(user_params)
      # update roles for users
      update_role(params[:user][:roles], @user)
      return redirect_to @user
    else
      return render 'edit_user'
    end
  end

  def destroy_user
    @user.destroy
    redirect_to users_path
  end

  def index_project
    @projects = Project.all
    if params[:project_filter_selected] == "all_projects"
      @projects = Project.all
    elsif params[:project_filter_selected] == "assigned_projects"
      @projects = current_user.assigned_projects
    elsif params[:project_filter_selected] == "create_projects"
      @projects = current_user.projects
    elsif params.has_key?("project_filter_selected") && params[:project_filter_selected].blank?
      flash.notice = "please choose a scope"
      return redirect_to administrators_index_project_path
    end
  end

  def index_task
    @tasks = Task.all
    if params[:task_filter_selected] == "all_tasks"
      @tasks = Task.all
    elsif params[:task_filter_selected] == "assigned_and_confirmed_tasks"
      @tasks = current_user.assigned_and_confirmed_tasks
    elsif params[:task_filter_selected] == "create_tasks"
      @tasks = current_user.tasks
    elsif params[:task_filter_selected] == "assigned_and_pending_tasks"
      @tasks = current_user.assigned_and_pending_tasks
    elsif params.has_key?("task_filter_selected") && params[:task_filter_selected].blank?
      flash.notice = "please choose a scope"
      return redirect_to administrators_index_task_path
    end

  end

  private
  def user_params
    params.require(:user).permit(:user_name, :email, :first_name, :last_name, :password, :password_confirmation, :activated)
  end

  def update_role(roles_id, user)
    # parameter roles indicate an array of role ids string
    # no roles are chosen
    if roles_id.blank?
      return user.role_maps.delete(user.role_maps.all)
    end
    #delete roles of user which are not chosen
    user.role_maps.all.each do |r|
      if roles_id.exclude?(r.role_id.to_s)
        r.destroy
      end
    end
    #add new choosed role to user
    roles_id.each do |r|
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
