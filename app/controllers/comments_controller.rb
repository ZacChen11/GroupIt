class CommentsController < ApplicationController
  before_action :is_admin_before_action,   only: [:edit, :update, :destroy]
  before_action :load_comment_before_action, only: [:edit, :update, :destroy]

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
  end

  def update
    @comment.edit = true
    if @comment.update(comment_params)
      redirect_to project_task_path(params[:project_id], @comment.task.id)
    else
      render 'edit'
    end
  end

  def destroy
    @task =  Task.find(params[:task_id])
    set_record_to_deleted(@comment)
    redirect_to project_task_path(params[:project_id], @task.id)
  end

  private
  def comment_params
    params.require(:comment).permit(:body)
  end
  def load_comment_before_action
    @comment = Comment.find_by(id: params[:id])
    if @comment.blank? || @comment.deleted
      flash.notice = "Comment doesn't exist !"
      redirect_to root_path
    end
  end

end
