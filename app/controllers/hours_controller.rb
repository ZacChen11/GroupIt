class HoursController < ApplicationController
  before_action :load_hour_before_action, only: [:show]

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
    @hour = Hour.find(params[:id])
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
  end


end
