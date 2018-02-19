class Comment < ActiveRecord::Base
  belongs_to :task
  validates :author, :body, :presence => true
end
