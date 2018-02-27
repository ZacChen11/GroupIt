class User < ActiveRecord::Base
  require 'csv'
  has_many :projects
  has_many :hours
  has_many :role_maps
  has_many :roles, through: :role_maps
  has_many :tasks
  before_save { self.email = email.downcase }
  validates :user_name,  presence: true, length: {maximum: 50}, uniqueness: {case_sensitive: false}
  validates :email,  presence: true, length: {maximum: 200}, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "inapporiate format"},
      uniqueness: {case_sensitive: false}
  validates :password,  presence: true, length: {minimum: 4}
  has_secure_password
  scope :created_between, lambda{ |start_time, end_time| where ('created_at BETWEEN ? And ?'), start_time, end_time }
  scope :user_status, lambda{ |status| where(:activated => status)}

  def self.to_csv
    attributes = %w{id user_name email first_name last_name total_work_time}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def check_role(role_name)
    roles.exists?(role_name: role_name)
  end

end
