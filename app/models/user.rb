class User < ActiveRecord::Base
  require 'csv'
  has_many :projects, dependent: :delete_all
  has_many :hours, dependent: :delete_all
  has_many :role_maps, dependent: :delete_all
  has_many :roles, through: :role_maps
  has_many :tasks, dependent: :delete_all
  has_many :comments, dependent: :delete_all
  before_save { self.email = email.downcase }
  validates :user_name,  presence: true, length: {maximum: 50}, uniqueness: true
  validates :email,  presence: true, length: {maximum: 200}, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "invalid email format"},
      uniqueness: {case_sensitive: false}
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: {minimum: 4}, if: :password_validation
  has_secure_password
  scope :created_between, lambda{ |start_time, end_time| where ('created_at BETWEEN ? And ?'), start_time, end_time }
  scope :user_status, lambda{ |status| where(:activated => status)}
  attr_accessor :password_validation
  after_initialize :set_password_validation_default_value
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

  private
  def set_password_validation_default_value
    self.password_validation = true
  end


end
