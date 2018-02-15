class Task < ActiveRecord::Base
  has_many :sub_tasks,  class_name: "Task", foreign_key: "parent_task_id"
  has_many :comments
  belongs_to :project
  belongs_to :parent_task, class_name: "Task"
  validates :title, :author, :description, :status, :assignee, :presence => true
end
