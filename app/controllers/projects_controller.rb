class ProjectsController < ApplicationController

  before_action :logged_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy, :filter]
  before_action :valid_project, only: [:show, :edit, :update, :destroy]


  def index
    @projects = Project.all
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
      redirect_to @project
    else
      render 'new'
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to @project
    else
      render 'edit'
    end
  end

  def filter
    # when select all projects
    if params[:filter_selected] == "All Projects"
      @projects = Project.all
      return render 'index'
    end
    if params[:filter_selected] == "My Projects"
      @projects = current_user.projects
      return render 'index'
    end
    flash.notice = "please choose a scope"
    return redirect_to projects_path
  end

  private
  def valid_project
    if !Project.find_by(id: params[:id])
      flash.notice = "Project doesn't exist !"
      redirect_to current_user
    end
  end

  def project_params
    params.require(:project).permit(:title, :description, :user_id)
  end

end
