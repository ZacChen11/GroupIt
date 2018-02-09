class TasksController < ApplicationController
  $jobNum = 0
  def task_params
    params.require(:task).permit(:title, :author, :description, :status, :parent_task)
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
    @project = Project.find(params[:project_id])
    @task = @project.tasks.find(params[:id])
    @comment = Comment.new
    @comment.task_id = @task.id
  end

  def edit
    @task = Project.find(params[:project_id]).tasks.find(params[:id])
  end

  def update
    @task = Project.find(params[:project_id]).tasks.find(params[:id])
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
    redirect_to project_path(@project)
  end

end
