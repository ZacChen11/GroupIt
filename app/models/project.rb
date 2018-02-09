class Project < ActiveRecord::Base
  has_many :tasks
  validates :author, :title, :description, :presence => true
end
