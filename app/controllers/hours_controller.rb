class HoursController < ApplicationController
  before_action :logged_in_user

  private def logged_in_user
    unless logged_in?
      flash.notice = "Please Log In"
      redirect_to root_path
    end
  end

  private def hour_params
    params.require(:hour).permit(:work_time, :task_id, :user_id, :explanation)
  end

  def create
    @hour = Hour.new(hour_params)
    @task = @hour.task
    if @hour.save
      #update user total work time
      user = @hour.user
      user.total_work_time += @hour.work_time
      user.save(validate: false)
      redirect_to project_task_path(@hour.task.project, @hour.task)
    else
      flash.notice = "Invalid Work Time"
      redirect_to :back
    end
  end

  def show
    @hour = Hour.find(params[:id])
  end


end
