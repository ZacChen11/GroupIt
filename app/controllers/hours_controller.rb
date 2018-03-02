class HoursController < ApplicationController
  before_action :logged_in_user

  def create
    @hour = Hour.new(hour_params)
    @hour.user_id = current_user.id
    @hour.task_id = params[:task_id]
    if @hour.save
      redirect_to project_task_path(@hour.task.project, @hour.task)
    else
      error_message = ""
      @hour.errors.full_messages.each do |m|
        error_message = error_message  + m + ". "
      end
        flash.notice = error_message
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


end
