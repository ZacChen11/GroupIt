class HoursController < ApplicationController
  before_action :load_hour_before_action, only: [:show, :edit, :update, :destroy]

  def create
    @hour = Hour.new(hour_params)
    @hour.user_id = current_user.id
    @hour.task_id = params[:task_id]
    if @hour.save
      redirect_to project_task_path(@hour.task.project, @hour.task)
    else
      flash.notice = @hour.errors.full_messages.join(". ")
      redirect_to :back
    end
  end

  def show
  end

  def edit
  end

  def update
    if @hour.update(hour_params)
      return redirect_to  project_task_hour_path(@hour.task.project, @hour.task, @hour)
    else
      return render 'edit'
    end
  end

  def destroy
    @task =  Task.find(params[:task_id])
    @hour.destroy
    redirect_to  project_task_path(@task.project, @task)
  end

  private
  def hour_params
    params.require(:hour).permit(:work_time, :explanation)
  end

  def load_hour_before_action
    @hour = Hour.find_by(id: params[:id])
    if @hour.blank?
      flash.notice = "Hour doesn't exist !"
      redirect_to root_path
    end
    # only allow participants and administrator access a task under a project
    if !current_user.has_role?("administrator") && !@hour.task.project.participants.exists?(current_user)
      flash.notice = "You don't have privilege !"
      return redirect_to root_path
    end
  end


end
