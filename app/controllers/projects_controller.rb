class ProjectsController < ApplicationController

  def project_params
    params.require(:project).permit(:title, :author, :description, :user_id)
  end

  def index
    @user = User.find(params[:user])
    @projects = @user.projects.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to project_path(@project)
    else
      render 'new'
    end
  end

  def destroy
    @project = Project.find(params[:id])
    user_id = @project.user_id
    @project.destroy
    redirect_to projects_path(:user => user_id)
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to project_path(@project)
    else
      render 'edit'
    end
  end

end
