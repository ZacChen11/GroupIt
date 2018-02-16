class CommentsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  def logged_in_user
    unless logged_in?
      flash.notice = "Please Log In"
      redirect_to root_path
    end
  end

  # Confirms only admin can edit/delete a comment.
  def correct_user
    unless current_user.admin
      flash.notice = "You don't have the privilege"
      redirect_to root_path
    end
  end

  def comment_params
    params.require(:comment).permit(:author_name, :body)
  end

  def create
    @comment = Comment.new(comment_params)
    # @project = Project.find(params[:project_id])
    @task = Task.find(params[:task_id])
    @comment.task_id = params[:task_id]
    if @comment.save
      redirect_to project_task_path(params[:project_id], @comment.task_id)
    else
      render 'tasks/show'
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      redirect_to project_task_path(params[:project_id], @comment.task.id, @comment.id)
    else
      render 'edit'
    end
  end

  def destroy
    @task =  Task.find(params[:task_id])
    @comment = @task.comments.find(params[:id])
    @comment.destroy
    redirect_to project_task_path(params[:project_id], @task.id)
  end

end
