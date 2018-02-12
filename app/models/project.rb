class Project < ActiveRecord::Base
  has_many :tasks
  belongs_to :user
  validates :author, :title, :description, :presence => true
end
