class HoursController < ApplicationController

  private def hour_params
    params.require(:hour).permit(:work_time, :task_id)
  end

  def create
    @hour = Hour.new(hour_params)
    @task = @hour.task
    if @hour.save
      redirect_to project_task_path(@hour.task.project, @hour.task)
    else
      flash.notice = "Invalid Work Time"
      redirect_to :back
    end

 end
end
