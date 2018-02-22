class Role < ActiveRecord::Base
  has_many :role_maps
  has_many :users, through: :role_maps
end
