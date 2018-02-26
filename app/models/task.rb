class Task < ActiveRecord::Base
  require 'csv'
  has_many :sub_tasks,  class_name: "Task", foreign_key: "parent_task_id"
  has_many :comments
  has_many :hours
  belongs_to :project
  belongs_to :parent_task, class_name: "Task"
  belongs_to :user
  validates :title, :description, :status, :assignee_id, :presence => true
  scope :created_between, lambda{ |start_time, end_time| where ('created_at BETWEEN ? And ?'), start_time, end_time }
  scope :task_status, lambda{ |status| where(:status => status)}

  def self.to_csv
    attributes = %w{id title total_work_time}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |task|
        csv << attributes.map{ |attr| task.send(attr) }
      end
    end
  end

end