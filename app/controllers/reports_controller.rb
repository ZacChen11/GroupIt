class ReportsController < ApplicationController

  before_action :is_reporter_before_action

  def generate
    @report = Report.new
    if params[:task_ids].present?
      records = Task.where(id: params[:task_ids])
    end
    if params[:user_ids].present?
      records = User.where(id: params[:user_ids])
    end
    respond_to do |format|
      format.html
      format.csv { send_data records.to_csv, filename: "report-#{Date.today}.csv" }
    end
  end

  def search
    @report = Report.new(params[:report])
    # check input starting time and ending time
    if @report.start_time.blank?
      # no starting time
      flash.now.notice = "please choose starting time"
      return render 'generate'
    end
    if @report.end_time.blank?
      # no ending time
      flash.now.notice = "please choose ending time"
      return render 'generate'
    end
    if @report.start_time >= @report.end_time
      # starting time >= ending time
      flash.now.notice = "ending time should be larger or equal to starting time, please choose again"
      return render 'generate'
    end

    if @report.task_or_user_checked == "task"
      if @report.task_status.present?
        # when choose task/task status
        @tasks = Task.created_between(@report.start_time, @report.end_time).task_status(@report.task_status)
      else
        # when choose task
        @tasks = Task.created_between(@report.start_time, @report.end_time)
      end
      return render 'generate'
    end

    if @report.task_or_user_checked == "user"
      if @report.user_activated.present?
        # when choose user/user status
        @report.user_activated = string_to_boolean(@report.user_activated)
        @users = User.created_between(@report.start_time, @report.end_time).user_activated(@report.user_activated)
      else
        # when choose user
        @users = User.created_between(@report.start_time, @report.end_time)
      end
      return render 'generate'
    end

    if @report.task_or_user_checked.blank?
      flash.now.notice = "choose task or user"
      return render 'generate'

    end
  end

  private
  def is_reporter_before_action
    if !current_user.has_role?("report manager")
      flash.notice = "You don't have the previlege"
      redirect_to current_user
    end
  end

  def string_to_boolean(string)
    if string == "true"
      return true
    else
      return false
    end
  end

end
