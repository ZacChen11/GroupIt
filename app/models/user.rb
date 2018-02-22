class User < ActiveRecord::Base
  has_many :projects
  has_many :hours
  has_many :role_maps
  has_many :roles, through: :role_maps
  before_save { self.email = email.downcase }
  validates :user_name,  presence: true, length: {maximum: 50}, uniqueness: {case_sensitive: false}
  validates :email,  presence: true, length: {maximum: 200}, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "inapporiate format"},
      uniqueness: {case_sensitive: false}
  validates :password,  presence: true, length: {minimum: 4}
  has_secure_password
end
