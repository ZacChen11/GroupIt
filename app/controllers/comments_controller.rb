class CommentsController < ApplicationController

  def create
    @comment = Comment.new(comment_params)
    @project = Project.find(params[:project_id])
    @task = Task.find(params[:task_id])
    project_id = params[:project_id]
    @comment.task_id = params[:task_id]
    if @comment.save
      redirect_to project_task_path(project_id, @comment.task_id)
    else
      render 'tasks/show'
    end

  end

  def comment_params
    params.require(:comment).permit(:author_name, :body)
  end
end
