class Project < ActiveRecord::Base
  has_many :tasks, dependent: :delete_all
  belongs_to :user
  validates :title, :description, :presence => true

end
