class User < ActiveRecord::Base
  require 'csv'
  has_many :projects
  has_many :hours
  has_many :role_maps
  has_many :roles, through: :role_maps
  has_many :tasks
  has_many :comments
  has_and_belongs_to_many :assigned_projects, class_name: "Project",  join_table: "assigned_projects_participants"
  has_and_belongs_to_many :assigned_tasks, class_name: "Task",  join_table: "assigned_tasks_assignees"

  before_save { self.email = email.downcase }
  before_save {self.user_name = user_name.delete(' ')}
  # before_destroy :release_all_associations
  # before_destroy :release_all_assigned_tasks
  validates :user_name,  presence: true, length: {maximum: 50}, uniqueness: {case_sensitive: false}
  validates :email,  presence: true, length: {maximum: 200}, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "invalid email format"},
      uniqueness: {case_sensitive: false}
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: {minimum: 4}, if: :password_validation
  after_initialize :set_password_validation_default_value
  has_secure_password
  attr_accessor :password_validation
  scope :created_between, lambda{ |start_time, end_time| where ('created_at BETWEEN ? And ?'), start_time, end_time }
  scope :user_activated, lambda{ |status| where(:activated => status)}


  def self.to_csv
    attributes = %w{id user_name email first_name last_name status total_work_time}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |user|
        csv << [user.id, user.user_name, user.email, user.first_name, user.last_name, user.status, user.user_total_work_time]
      end
    end
  end

  def has_role?(role_name)
    roles.exists?(role_name: role_name)
  end

  def user_total_work_time
    hours.validated_hours.map{|t| t.work_time}.sum
  end

  def assigned_and_confirmed_tasks
    assigned_tasks.validated_tasks.where(assignment_confirmed_user_id: self.id)
  end

  def assigned_and_pending_tasks
    assigned_tasks.validated_tasks.where(assignment_confirmed_user_id: nil)
  end

  # tasks which are created by the user and the user can also access them
  def create_tasks_and_can_access
    returned_tasks = []
    tasks.validated_tasks.each do |task|
      if task.project.participants.include?(self)
        returned_tasks = returned_tasks + [task]
      end
    end
    return returned_tasks
  end

  # tasks that created by user without being assigned to himself
  def create_tasks_without_being_assigned
    create_tasks_and_can_access - assigned_and_confirmed_tasks - assigned_and_pending_tasks
  end

  def have_accessed_tasks
    returned_tasks = []
    assigned_projects.validated_projects.each do |project|
      returned_tasks = returned_tasks + project.tasks.validated_tasks
    end
    returned_tasks - assigned_and_confirmed_tasks - assigned_and_pending_tasks - tasks.validated_tasks
  end

  # return the tasks by its relevant: confirmed > pending > create > others
  def return_tasks_by_relevant
    assigned_and_confirmed_tasks + assigned_and_pending_tasks + create_tasks_without_being_assigned + have_accessed_tasks
  end

  def return_admin_tasks_by_relevant
    assigned_and_confirmed_tasks + assigned_and_pending_tasks + create_tasks_without_being_assigned + (Task.all.validated_tasks - assigned_and_confirmed_tasks - assigned_and_pending_tasks - create_tasks_without_being_assigned)
  end

  def return_taks_of_type(tasks, type)
    tasks.select{|task| task.task_type_id == TaskType.find_by(name: type).id}
  end

  def create_projects_and_participate
   projects.validated_projects - ( projects.validated_projects - assigned_projects.validate_projects )
  end

  def update_role(roles_id)
    # parameter roles indicate an array of role ids string
    # no roles are chosen
    if roles_id.blank?
      return role_maps.delete(role_maps.all)
    end
    #delete roles of user which are not chosen
    role_maps.all.each do |role_map|
      if roles_id.exclude?(role_map.role_id.to_s)
        role_map.destroy
      end
    end
    #add new choosed role to user
    roles_id.each do |role_id|
      if !role_maps.exists?(role_id: role_id)
        role_maps.create(role_id: role_id)
      end
    end
  end

  def status
    if activated
      "Active"
    else
      "Inactive"
    end
  end

  private
  def set_password_validation_default_value
    self.password_validation = true
  end



end
