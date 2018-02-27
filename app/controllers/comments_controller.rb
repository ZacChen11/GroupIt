class CommentsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  def create
    @comment = Comment.new(comment_params)
    @task = Task.find(params[:task_id])
    @comment.task_id = @task.id
    if @comment.save
      redirect_to project_task_path(@comment.task.project, @comment.task)
    else
      flash.notice = "Comment can't be empty"
      redirect_to :back
    end
  end

  def edit
    @task = Task.find(params[:task_id])
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      redirect_to project_task_path(params[:project_id], @comment.task.id)
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


  private
  # Confirms only admin can edit/delete a comment.
  def correct_user
    unless current_user.check_role("administrator")
      flash.notice = "You don't have the privilege"
      redirect_to current_user
    else
      unless Comment.find_by(id: params[:id])
        flash.notice = "Comment doesn't exist !"
        redirect_to current_user
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:author, :body, :edit)
  end


end
