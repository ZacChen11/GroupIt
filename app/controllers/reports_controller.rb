class ReportsController < ApplicationController

  before_action :is_reporter_before_action

  def generate
    @report = Report.new
    respond_to do |format|
      format.html
      format.csv{
        @report = Report.new(params[:report])
        #search records again based on the params
        load_records_from_search
        if @tasks
          records = @tasks
        else
          records = @users
        end
        #write out records into a csv file
        send_data records.to_csv, filename: "report-#{Date.today}.csv" }
    end
  end

  def search
    @report = Report.new(params[:report])
    if @report.invalid?
      return render 'generate'
    end
    if @report.task_or_user_checked.blank?
      flash.now.notice = "choose task or user"
    end
    load_records_from_search
    return render 'generate'
  end

  private
  def is_reporter_before_action
    if !current_user.has_role?("report manager")
      flash.notice = "You don't have the privilege"
      redirect_to current_user
    end
  end

  def string_to_boolean(input_string)
    if input_string == "true"
      return true
    else
      return false
    end
  end

  def load_records_from_search
    if @report.task_or_user_checked == "task"
      @tasks = Task.validated_tasks.created_between(@report.start_time, @report.end_time)
      if @report.task_status.present?
        # when choose task and task status
        @tasks = @tasks.task_status(@report.task_status)
        if @report.task_type_id.present?
          @tasks = @tasks.task_type(@report.task_type_id)
        end
      end
      if @report.task_type_id.present?
        @tasks = @tasks.task_type(@report.task_type_id)
      end
    elsif @report.task_or_user_checked == "user"
      @users = User.created_between(@report.start_time, @report.end_time)
      if @report.user_activated.present?
        # when choose user and user status
        @report.user_activated = string_to_boolean(@report.user_activated)
        @users = @users.user_activated(@report.user_activated)
      end
    end
  end

end
