class Project < ActiveRecord::Base
  has_many :tasks
  belongs_to :user
  validates :title, :description, :presence => true
end
