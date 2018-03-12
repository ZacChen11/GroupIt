class Project < ActiveRecord::Base
  has_many :tasks, dependent: :delete_all
  belongs_to :user
  has_and_belongs_to_many :participants, class_name: "User", foreign_key: "participant_id"
  validates :title, :description, :presence => true

end
