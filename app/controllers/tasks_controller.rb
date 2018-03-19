class TasksController < ApplicationController
  before_action :load_task_before_action, only: [:show, :edit, :update, :destroy, :assign_task]
  before_action :is_the_correct_user_before_action, only: [:accept_task]

  def new
    @project = Project.find(params[:project_id])
    @task = Task.new
  end

  def new_subtask
    @project = Project.find(params[:project_id])
    @parent_task = Task.find(params[:id])
    @task = @parent_task.sub_tasks.new
    @task.project_id = @project.id
  end

  def create
    @project = Project.find(params[:project_id])
    @task = Task.new(task_params)
    @task.project_id = @project.id
    @task.user_id = current_user.id
    @task.task_type_id = params[:task][:task_type]
    if @task.save
      @task.update_assignee(params[:task][:assignees_id])
      redirect_to  project_task_path(@task.project, @task)
    else
      render 'new'
    end
  end

  def create_subtask
    @project = Project.find(params[:project_id])
    @parent_task = Task.find(params[:id])
    @task = Task.new(task_params)
    @task.project_id = @project.id
    @task.parent_task_id = @parent_task.id
    @task.user_id = current_user.id
    @task.task_type_id = params[:task][:task_type]
    if @task.save
      @task.update_assignee(params[:task][:assignees_id])
      redirect_to project_task_path(@task.project, @task)
    else
      render 'new_subtask'
    end
  end

  def show
    @hour = Hour.new
    @hour.task_id = @task.id
    @comment = Comment.new
    @comment.task_id = @task.id
  end

  def edit
    @project = Project.find(params[:project_id])
  end

  def update
    @project = Project.find(params[:project_id])
    @task.update_task_type(params[:task][:task_type])
    if @task.update(task_params)
      @task.update_assignee(params[:task][:assignees_id])
      redirect_to project_task_path(@task.project_id, @task.id)
    else
      render 'edit'
    end
  end

  def destroy
    @project =  Project.find(params[:project_id])
    set_record_to_deleted(@task)
    @task.set_subtasks_comments_hours_to_deleted
    redirect_to @project
  end

  def assign_task
    if params.has_key?("commit")
      if params.has_key?("task")
        # after submitting the form, assign task if choose any users
        @task.update_assignee(params[:task][:assignees_id])
      else
        # remove previous assignees if didn't choose any users
        @task.update_assignee([])
      end
      return redirect_to project_task_path(@task.project, @task)
    end
  end

  def index_task
    # return the tasks by its relevant: confirmed > pending > create > others
    @tasks = current_user.return_tasks_by_relevant
    if params[:task_filter_selected] == "all_tasks"
      @tasks = current_user.return_tasks_by_relevant
    elsif params[:task_filter_selected] == "confirmed_tasks"
      @tasks = current_user.assigned_and_confirmed_tasks
    elsif params[:task_filter_selected] == "create_tasks"
      @tasks = current_user.create_tasks_and_can_access
    elsif params[:task_filter_selected] == "pending_tasks"
      @tasks = current_user.assigned_and_pending_tasks
    elsif params[:task_filter_selected] == "other_accessed_tasks"
      @tasks = current_user.have_accessed_tasks
    elsif params[:task_filter_selected] == "feature"
      @tasks = current_user.return_taks_of_type(current_user.return_tasks_by_relevant, "Feature")
    elsif params[:task_filter_selected] == "bug"
      @tasks = current_user.return_taks_of_type(current_user.return_tasks_by_relevant, "Bug")
    elsif params[:task_filter_selected] == "improvement"
      @tasks = current_user.return_taks_of_type(current_user.return_tasks_by_relevant, "Improvement")

    elsif params.has_key?("task_filter_selected") && params[:task_filter_selected].blank?
      flash.notice = "please choose a scope"
      return redirect_to index_task_user_path(current_user)
    end
  end

  def accept_task
    @task = Task.find_by(id: params[:id])
    @user = User.find_by(id: params[:user_id])
    if params.has_key?("commit")
      if params[:accept]
        @task.update(assignment_confirmed_user_id: params[:user_id])
        @task.update(assignment_status: "Confirmed")
      else
        @task.update(assignment_confirmed_user_id: nil)
        @task.update(assignment_status: "Pending")
      end
      return redirect_to   project_task_path(@task.project, @task)
    end
    if params.has_key?("accept")
      @task.update(assignment_confirmed_user_id: params[:user_id])
      @task.update(assignment_status: "Confirmed")
      return redirect_to  project_task_path(@task.project, @task)
    end
  end


  private
  def load_task_before_action
    @task = Task.find_by(id: params[:id])
    if @task.blank? || @task.deleted
      flash.notice = "Task doesn't exist !"
      return redirect_to root_path
    end
    # only allow participants and administrator access a task under a project
    if !current_user.has_role?("administrator") && !@task.project.participants.exists?(current_user)
      flash.notice = "You don't have privilege !"
      return redirect_to root_path
    end
  end

  def is_the_correct_user_before_action
    if current_user.id.to_s != params[:user_id] || Task.find_by(id: params[:id]).assignees.exclude?(current_user)
      flash.notice = "You don't have privilege !"
      return redirect_to root_path
    end
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :assignees_id)
  end


end
