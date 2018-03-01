class Report
  include ActiveModel::Model
  attr_accessor :start_time, :end_time, :task_checked, :task_status, :user_checked, :user_status
end