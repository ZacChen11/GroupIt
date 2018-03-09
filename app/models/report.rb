class Report
  include ActiveModel::Model
  attr_accessor :start_time, :end_time, :task_or_user_checked, :task_status, :user_activated
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :validate_start_time_with_end_time

  private
  def validate_start_time_with_end_time
    if start_time >= end_time
      errors.add(:base, "start time should be small than end time,  please choose again")
    end
  end
end