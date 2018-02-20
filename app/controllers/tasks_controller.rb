class TasksController < ApplicationController
  before_action :logged_in_user, only: [:show, :new, :create, :edit, :update, :destroy]
  before_action :valid_task, only: [:show, :edit, :update, :destroy]


  private def logged_in_user
    unless logged_in?
      flash.notice = "Please Log In"
      redirect_to root_path
    end
  end

  private def valid_task
    unless Task.find_by(id: params[:id])
      flash.notice = "Task doesn't exist !"
      redirect_to current_user
    end
  end

  private def task_params
    params.require(:task).permit(:title, :author, :description, :status, :assignee_id, :parent_task_id)
  end

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
    # @project = Project.find(params[:project_id])
    # @task = @project.tasks.find(params[:id])
    @task = Task.find(params[:id])
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

end
