class ProjectsController < ApplicationController

  before_action :load_project_before_action, only: [:show, :edit, :update, :destroy, :invite_participant]


  def index
    @projects = current_user.projects + current_user.assigned_projects
    if params[:project_filter_selected] == "all_projects"
      @projects = current_user.projects + current_user.assigned_projects
    elsif params[:project_filter_selected] == "assigned_projects"
      @projects = current_user.assigned_projects
    elsif params[:project_filter_selected] == "create_projects"
      @projects = current_user.projects
    elsif params.has_key?("project_filter_selected") && params[:project_filter_selected].blank?
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
      update_participant(params[:project][:participants_id], @project)
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
      update_participant(params[:project][:participants_id], @project)
      redirect_to @project
    else
      render 'edit'
    end
  end

  def invite_participant
    if params.has_key?("commit")
      if params.has_key?("project")
        # invite user if choose any users
        update_participant(params[:project][:participants_id], @project)
      else
        # remove all participants if no user is chosen
        update_participant([], @project)
      end
      return redirect_to @project
    end
  end

  private
  def load_project_before_action
    @project = Project.find_by(id: params[:id])
    if @project.blank?
      flash.notice = "Project doesn't exist !"
      return redirect_to root_path
    end
    # only allow author, participants and administrator access a project
    if !current_user.has_role?("administrator") && @project.user != current_user && !@project.participants.exists?(current_user)
      flash.notice = "You don't have privilege !"
      return redirect_to root_path
    end
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end

  def update_participant(participants_id, project)
    # parameter participants indicate an array of participants ids string
    if participants_id.blank?
      # remove user from assigned task
      project.participants.each do |p|
        remove_task_assignee(project, p)
      end
      return project.participants.delete(project.participants.all)
    end
    project.participants.each do |p|
      if participants_id.exclude?(p.id.to_s)
        # remove user from assigned task
        remove_task_assignee(project, p)
        project.participants.delete(p)
      end
    end
    #add new participant to project
    participants_id.each do |p|
      if !project.participants.exists?(id: p)
        user = User.find_by(id: p)
        project.participants << user
      end
    end
  end

  def remove_task_assignee(project, user)
    project.tasks.each do |t|
      t.assignees.delete(user)
      t.update_assignment_status
    end
  end

end
