class Task < ActiveRecord::Base
  require 'csv'
  has_many :sub_tasks,  class_name: "Task", foreign_key: "parent_task_id", dependent: :delete_all
  has_many :comments, dependent: :delete_all
  has_many :hours, dependent: :delete_all
  belongs_to :project
  belongs_to :parent_task, class_name: "Task"
  belongs_to :user
  validates :title, :description, :status, :presence => true
  scope :created_between, lambda{ |start_time, end_time| where ('created_at BETWEEN ? And ?'), start_time, end_time }
  scope :task_status, lambda{ |status| where(:status => status)}

  def self.to_csv
    attributes = %w{id title total_work_time}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |task|
        csv << [task.id, task.title, task.check_work_time]
      end
    end
  end

  def check_work_time
    if sub_tasks.present?
      return hours.map{|t| t.work_time}.sum + sub_tasks.map{|s| s.check_work_time}.sum
    else
      return hours.map{|t| t.work_time}.sum
    end
  end

end