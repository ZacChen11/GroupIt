class User < ActiveRecord::Base
  has_many :projects
  before_save { self.email = email.downcase }
  validates :user_name,  presence: true, length: {maximum:  50}
  validates :email,  presence: true, length: {maximum: 200}, format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i},
      uniqueness: {case_sensitive: false}
  validates :password,  presence: true, length: {minimum:  4}
  has_secure_password
end
