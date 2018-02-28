class ReportsController < ApplicationController
  before_action :logged_in_user, :is_reporter, only: [:generate, :search]

  def generate
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
    # check input starting time and ending time
    if params[:start_time].present? && params[:end_time].blank?
      # no ending time
      flash.now.notice = "please choose ending time"
      return render 'generate'
    end
    if params[:start_time].blank? && params[:end_time].present?
      # no starting time
      flash.now.notice = "please choose starting time"
      return render 'generate'
    end
    if params[:start_time].present? && params[:end_time].present? && params[:start_time] >= params[:end_time]
      # starting time >= ending time
      flash.now.notice = "ending time should be larger or equal to starting time, please choose again"
      return render 'generate'
    end
    if params[:start_time].blank? && params[:end_time].blank?
      # no input time
      flash.now.notice = "please choose time"
      return render 'generate'
    end
    # check task and user
    if params[:task_checked].present? && params[:user_checked].present?
      # when choose user/task
      flash.now.notice = "can't choose task and user at the same time, choose again"
      return render 'generate'
    end
    if params[:task_checked].present?
      if params[:status_selected].present?
        # when choose task/task status
        @tasks = Task.created_between(params[:start_time], params[:end_time]).task_status(params[:status_selected])
      else
        # when choose task
        @tasks = Task.created_between(params[:start_time], params[:end_time])
      end
      return render 'generate'
    end
    if params[:user_checked].present?
      if params[:user_status_selected].present?
        # when choose user/user status
        params[:user_status_selected] = string_to_boolean(params[:user_status_selected])
        @users = User.created_between(params[:start_time], params[:end_time]).user_status(params[:user_status_selected])
      else
        # when choose user
        @users = User.created_between(params[:start_time], params[:end_time])
      end
      return render 'generate'
    end
    flash.now.notice = "please choose task or user"
    return render 'generate'
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
