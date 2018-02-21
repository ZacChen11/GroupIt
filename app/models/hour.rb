class Hour < ActiveRecord::Base
  belongs_to :task
  validates :work_time, :presence => true, numericality: { greater_than: 0  }
end
