class ReportsController < ApplicationController

  before_action :logged_in_user, :is_reporter, only: [:generate, :search]


  def generate
    @report = Report.new
    if params[:tasks].present?
      records = export_task(params[:tasks])
    end
    if params[:users].present?
      records = export_user(params[:users])
    end

    respond_to do |format|
      format.html
      format.csv { send_data records.to_csv, filename: "report-#{Date.today}.csv" }
    end
  end

  def search
    @report = Report.new(params[:report])
    # check input starting time and ending time
    if @report.start_time.present? && @report.end_time.blank?
      # no ending time
      flash.now.notice = "please choose ending time"
      return render 'generate'
    end
    if @report.start_time.blank? && @report.end_time.present?
      # no starting time
      flash.now.notice = "please choose starting time"
      return render 'generate'
    end
    if @report.start_time.present? && @report.end_time.present? && @report.start_time >= @report.end_time
      # starting time >= ending time
      flash.now.notice = "ending time should be larger or equal to starting time, please choose again"
      return render 'generate'
    end
    if @report.start_time.blank? && @report.end_time.blank?
      # no input time
      flash.now.notice = "please choose time"
      return render 'generate'
    end

    # check task and user
    if @report.task_checked.present? &&@report.user_checked.present?
      # when choose user/task
      flash.now.notice = "can't choose task and user at the same time, choose again"
      return render 'generate'
    end
    if @report.task_checked.present?
      if @report.task_status.present?
        # when choose task/task status
        @tasks = Task.created_between(@report.start_time, @report.end_time).task_status(@report.task_status)
      else
        # when choose task
        @tasks = Task.created_between(@report.start_time, @report.end_time)
      end
      return render 'generate'
    end
    if@report.user_checked.present?
      if @report.user_status.present?
        # when choose user/user status
        @report.user_status = string_to_boolean(@report.user_status)
        @users = User.created_between(@report.start_time, @report.end_time).user_status(@report.user_status)
      else
        # when choose user
        @users = User.created_between(@report.start_time, @report.end_time)
      end
      return render 'generate'
    end
    if @report.task_checked.blank? && @report.user_checked.blank?
      flash.now.notice = "choose task or user"
      return render 'generate'
    end
  end

  private
  def export_task(a)
    records = Task.where(id: a.each{ |t| t})
    return records
  end

  def export_user(a)
    records = User.where(id: a.each{ |t| t})
    return records
  end

  def is_reporter
    if !current_user.check_role("report manager")
      flash.notice = "You don't have the previlege"
      redirect_to current_user
    end
  end

  def string_to_boolean(s)
    if s == "true"
      return true
    else
      return false
    end
  end

end
