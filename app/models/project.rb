class Project < ActiveRecord::Base
  has_many :tasks, dependent: :delete_all
  belongs_to :user
  has_and_belongs_to_many :participants, class_name: "User", join_table: "assigned_projects_participants"
  validates :title, :description, :presence => true

  # return all the users who can access the task
  def return_task_assignment_candidates
    [user] + participants
  end

end
