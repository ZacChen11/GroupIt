class Project < ActiveRecord::Base
  has_many :tasks, dependent: :delete_all
  belongs_to :user
  has_and_belongs_to_many :participants, class_name: "User", join_table: "assigned_projects_participants"
  validates :title, :description, :presence => true
  scope :validated_projects, ->{where(deleted: false)}


  def add_participant(user)
    participants << user
  end

  def update_participant(participants_id)
    # parameter participants indicate an array of participants ids string
    if participants_id.blank?
      # remove user from assigned task
      participants.each do |p|
        remove_task_assignee(p)
      end
      return participants.delete(participants.all)
    end
    participants.each do |p|
      if participants_id.exclude?(p.id.to_s)
        # remove user from assigned task
        remove_task_assignee(p)
        participants.delete(p)
      end
    end
    #add new participant to project
    participants_id.each do |p|
      if !participants.exists?(id: p)
        user = User.find_by(id: p)
        add_participant(user)
      end
    end
  end

  def remove_task_assignee(user)
    tasks.each do |t|
      t.assignees.delete(user)
      t.update_assignment_status
    end
  end

  def set_tasks_to_deleted
    self.tasks.each do |task|
      task.update(deleted: true)
      task.set_subtasks_comments_hours_to_deleted
    end
  end



end
