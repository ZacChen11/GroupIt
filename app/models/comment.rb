class Comment < ActiveRecord::Base
  belongs_to :task
  validates :author_name, :body, :presence => true
end
