class Task < ActiveRecord::Base
  require 'csv'
  has_many :sub_tasks,  class_name: "Task", foreign_key: "parent_task_id"
  has_many :comments, dependent: :delete_all
  has_many :hours, dependent: :delete_all
  belongs_to :project
  belongs_to :parent_task, class_name: "Task"
  belongs_to :user
  has_and_belongs_to_many :assignees, class_name: "User",  join_table: "assigned_tasks_assignees"
  belongs_to :task_type

  validates :title, :description, :status, :task_type, :presence => true
  scope :created_between, lambda{ |start_time, end_time| where ('created_at BETWEEN ? And ?'), start_time, end_time }
  scope :task_status, lambda{ |status| where(:status => status)}
  scope :task_type, lambda{ |type_id| where(:task_type_id => type_id)}
  scope :validated_tasks, ->{where(deleted: false)}

  def self.to_csv
    attributes = %w{id title type status total_work_time}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |task|
        csv << [task.id, task.title, task.task_type.name, task.status, task.task_total_work_time]
      end
    end
  end

  def without_subtask_work_time
    hours.validated_hours.map{|t| t.work_time}.sum
  end

  def task_total_work_time
    without_subtask_work_time + sub_tasks.map{|s| s.task_total_work_time}.sum
  end

  def update_assignment_status
    if assignees.count == 0
      update(assignment_status: "To Be Assigned", assignment_confirmed_user_id: nil)
    elsif assignees.count == 1
      update(assignment_status: "Confirmed", assignment_confirmed_user_id: assignees.first.id)
    elsif assignees.count > 1
      if assignment_confirmed_user_id == nil || assignees.map(&:id).exclude?(assignment_confirmed_user_id)
        update(assignment_status: "Pending", assignment_confirmed_user_id: nil)
      end
    end
  end

  def update_task_type(type)
    # parameter type is the string of task type id
    if type != task_type_id.to_s
      # when the type of a task is changed, task will delete this type and add a new type
      self.task_type.tasks.delete(self)
      self.task_type = TaskType.find_by(id: type)
    end
  end

  def update_assignee(assignees_id)
    # parameter participants indicate an array of participants ids string
    if assignees_id.blank?
      assignees.delete(assignees.all)
    else
      assignees.all.each do |assignee|
        if assignees_id.exclude?(assignee.id.to_s)
          assignees.delete(assignee)
        end
      end
      #add new participant to project
      assignees_id.each do |id|
        if !assignees.exists?(id: id)
          user = User.find_by(id: id)
          assignees << user
        end
      end
    end
    # update task assignment status
    update_assignment_status
  end

  def set_subtasks_comments_hours_to_deleted
    comments.update_all(deleted: true)
    hours.update_all(deleted: true)
    self.sub_tasks.each do |sub_task|
      sub_task.update(deleted: true)
      sub_task.set_subtasks_comments_hours_to_deleted
    end
  end

end