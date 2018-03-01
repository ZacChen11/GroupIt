class TasksController < ApplicationController
  before_action :logged_in_user, only: [:show, :new, :create, :edit, :update, :destroy, :assign_task]
  before_action :valid_task, only: [:show, :edit, :update, :destroy, :assign_task]


  def new
    @project = Project.find(params[:project_id])
    @task = Task.new
  end

  def create
    @project = Project.find(params[:project_id])
    @task = @project.tasks.new(task_params)
    if @task.save
      redirect_to  project_task_path(@task.project_id, @task.id)
    else
      render 'new'
    end
  end

  def show
    @task = Task.find(params[:id])
    @hour = Hour.new
    @hour.task_id = @task.id
    @comment = Comment.new
    @comment.task_id = @task.id
  end

  def edit
    @project = Project.find(params[:project_id])
    @task = Task.find(params[:id])
  end

  def update
    @project = Project.find(params[:project_id])
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to project_task_path(@task.project_id, @task.id)
    else
      render 'edit'
    end
  end

  def destroy
    @project =  Project.find(params[:project_id])
    @task = @project.tasks.find(params[:id])
    @task.destroy
    redirect_to @project
  end

  def assign_task
    @task = Task.find(params[:id])
    if params.has_key?("task")
      if @task.update(assignee_id: params[:task][:assignee_id])
        return redirect_to project_task_path(@task.project, @task)
      end
    end
  end

  private
  def valid_task
    if !Task.find_by(id: params[:id])
      flash.notice = "Task doesn't exist !"
      redirect_to current_user
    end
  end

  def task_params
    params.require(:task).permit(:title, :user_id, :description, :status, :assignee_id, :parent_task_id)
  end



end
