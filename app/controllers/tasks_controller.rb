class TasksController < ApplicationController
  before_action :load_task_before_action, only: [:show, :edit, :update, :destroy, :assign_task]

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
      update_assignee(params[:task][:assignees_id], @task)
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
      update_assignee(params[:task][:assignees_id], @task)
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
    update_task_type(params[:task][:task_type], @task)
    if @task.update(task_params)
      update_assignee(params[:task][:assignees_id], @task)
      redirect_to project_task_path(@task.project_id, @task.id)
    else
      render 'edit'
    end
  end

  def destroy
    @project =  Project.find(params[:project_id])
    @task.destroy
    redirect_to @project
  end

  def assign_task
    if params.has_key?("commit")
      if params.has_key?("task")
        # after submitting the form, assign task if choose any users
        update_assignee(params[:task][:assignees_id], @task)
      else
        # remove previous assignees if didn't choose any users
        update_assignee([], @task)
      end
      return redirect_to project_task_path(@task.project, @task)
    end

  end

  private
  def load_task_before_action
    @task = Task.find_by(id: params[:id])
    if @task.blank?
      flash.notice = "Task doesn't exist !"
      return redirect_to root_path
    end
    # only allow author, participants and administrator access a task under a project
    if !current_user.has_role?("administrator") && @task.project.user != current_user && !@task.project.participants.exists?(current_user)
      flash.notice = "You don't have privilege !"
      return redirect_to root_path
    end

  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :assignees_id)
  end

  def update_task_type(type, task)
    # parameter type is the string of task type id
    if type != task.task_type.id.to_s
      # when the type of a task is changed, task will delete this type and add a new type
      task.task_type.tasks.delete(task)
      task.task_type = TaskType.find_by(id: type)
    end
  end

  def update_assignee(assignees_id, task)
    # parameter participants indicate an array of participants ids string
    if assignees_id.blank?
      task.assignees.delete(task.assignees.all)
    else
      task.assignees.all.each do |assignee|
        if assignees_id.exclude?(assignee.id.to_s)
          task.assignees.delete(assignee)
        end
      end
      #add new participant to project
      assignees_id.each do |id|
        if !task.assignees.exists?(id: id)
          user = User.find_by(id: id)
          task.assignees << user
        end
      end
    end
    # update task assignment status
    task.update_assignment_status
  end

end
