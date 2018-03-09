class ReportsController < ApplicationController

  before_action :is_reporter_before_action

  def generate
    @report = Report.new
    # if params[:task_ids].present?
    #   records = Task.where(id: params[:task_ids])
    # end
    # if params[:user_ids].present?
    #   records = User.where(id: params[:user_ids])
    # end
    respond_to do |format|
      format.html
      format.csv {
        #search records again based on the params
        if params[:report][:task_or_user_checked] == "task"
          records = Task.created_between(params[:report][:start_time], params[:report][:end_time])
          if params[:report][:task_status].present?
            # when choose task and task status
            records = records.task_status(params[:report][:task_status])
          end
        end
        if params[:report][:task_or_user_checked] == "user"
          records = User.created_between(params[:report][:start_time], params[:report][:end_time])
          if params[:report][:user_activated].present?
            # when choose user and user status
            params[:report][:user_activated] = string_to_boolean(params[:report][:user_activated])
            records = records.user_activated(params[:report][:user_activated])
          end
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
    # # validate input starting time and ending time
    # if @report.start_time.blank?
    #   # no starting time
    #   flash.now.notice = "please choose start time"
    #   return render 'generate'
    # elsif @report.end_time.blank?
    #   # no ending time
    #   flash.now.notice = "please choose end time"
    #   return render 'generate'
    # elsif @report.start_time >= @report.end_time
    #   # starting time >= ending time
    #   flash.now.notice = "ending time should be larger or equal to starting time, please choose again"
    #   return render 'generate'
    # end

    # load records based on search condition
    if @report.task_or_user_checked == "task"
      @tasks = Task.created_between(@report.start_time, @report.end_time)
      if @report.task_status.present?
        # when choose task and task status
        @tasks = @tasks.task_status(@report.task_status)
      end
    end
    if @report.task_or_user_checked == "user"
      @users = User.created_between(@report.start_time, @report.end_time)
      if @report.user_activated.present?
        # when choose user and user status
        @report.user_activated = string_to_boolean(@report.user_activated)
        @users = @users.user_activated(@report.user_activated)
      end
    end
    if @report.task_or_user_checked.blank?
      flash.now.notice = "choose task or user"
    end
    return render 'generate'
  end

  private
  def is_reporter_before_action
    if !current_user.has_role?("report manager")
      flash.notice = "You don't have the privelege"
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

end
