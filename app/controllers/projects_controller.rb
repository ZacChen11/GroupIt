class ProjectsController < ApplicationController

  before_action :load_project_before_action, only: [:show, :edit, :update, :destroy]


  def index
    @projects = Project.all
    # when select all projects
    if params[:filter_selected] == "all_projects"
      @projects = Project.all
    elsif params[:filter_selected] == "my_projects"
      @projects = current_user.projects
    elsif params.has_key?("filter_selected") && params[:filter_selected].blank?
      flash.notice = "please choose a scope"
      return redirect_to projects_path
    end
  end

  def show
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user_id = current_user.id
    if @project.save
      redirect_to @project
    else
      render 'new'
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project
    else
      render 'edit'
    end
  end

  private
  def load_project_before_action
    @project = Project.find_by(id: params[:id])
    if @project.blank?
      flash.notice = "Project doesn't exist !"
      redirect_to current_user
    end
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end

end
