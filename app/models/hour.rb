class Hour < ActiveRecord::Base
  belongs_to :task
  belongs_to :user
  validates :work_time, :presence => true, numericality: { greater_than: 0}
  validates :explanation, :presence => true
end
