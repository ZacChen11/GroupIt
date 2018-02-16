class TasksController < ApplicationController
  before_action :logged_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

  $jobNum = 0

  def logged_in_user
    unless logged_in?
      flash.notice = "Please Log In"
      redirect_to root_path
    end
  end

  def task_params
    params.require(:task).permit(:title, :author, :description, :status, :assignee, :parent_task_id)
  end

  def new
    @task = Task.new
  end

  def create
    $jobNum += 1
    @task = Task.new(task_params)
    @task.job_number = $jobNum
    @task.project_id = params[:project_id]
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
    @task = Task.find(params[:id])
  end

  def update
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

  def assign
    fail
    # @task.assignee = params[:assignee]
    # redirect_to projects_path
  end

end
