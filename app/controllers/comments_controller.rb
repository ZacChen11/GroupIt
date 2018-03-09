class CommentsController < ApplicationController
  before_action :is_admin_before_action,   only: [:edit, :update, :destroy]

  def create
    @comment = Comment.new(comment_params)
    @task = Task.find(params[:task_id])
    @comment.task_id = @task.id
    @comment.user_id = current_user.id
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
    @comment.edit = true
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
  def is_admin_before_action
    if !current_user.has_role?("administrator")
      # when the user is not administrator
      flash.notice = "You don't have the privilege"
      return redirect_to current_user
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

end
