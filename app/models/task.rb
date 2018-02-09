class Task < ActiveRecord::Base
  belongs_to :project
  has_many :tasks
  has_many :comments
  validates :title, :author, :description, :status, :presence => true
end
