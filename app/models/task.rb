class Task < ActiveRecord::Base
  has_many :sub_tasks,  class_name: "Task", foreign_key: "parent_task_id"
  has_many :comments
  has_many :hours
  belongs_to :project
  belongs_to :parent_task, class_name: "Task"
  validates :title, :author, :description, :status, :assignee_id, :presence => true
end
