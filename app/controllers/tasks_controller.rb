class TasksController < ApplicationController
  # before_action :logged_in_user, only: [:show, :new, :create, :edit, :update, :destroy]
  # before_action :correct_user,   only: [:show, :new, :create, :edit, :update, :destroy]
  #
  # def logged_in_user
  #   unless logged_in?
  #     redirect_to login_path
  #   end
  # end
  #
  # # Confirms the correct user or the admin user.
  # def correct_user
  #   project = Project.find(params[:project_id])
  #   @user = User.find(project.user_id)
  #   # When the user is not the administrator
  #   if params[:admin] == nil
  #     redirect_to login_path unless @user == current_user
  #   end
  # end


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
    #if the task is a sub task
    if @task.parent_task != nil
      @task.task_id = @task.parent_task
    end
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
    # @task.tasks.all.each do |t|
    #   t.destroy
    # end
    @task.destroy
    redirect_to @project
  end

end
