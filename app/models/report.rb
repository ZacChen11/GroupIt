class Report
  include ActiveModel::Model
  attr_accessor :start_time, :end_time, :task_or_user_checked, :task_status, :user_activated
end