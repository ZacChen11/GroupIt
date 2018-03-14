# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(role_name: 'administrator')
Role.create(role_name: 'developer')
Role.create(role_name: 'report manager')
TaskType.create(name: 'Feature')
TaskType.create(name: 'Bug')
TaskType.create(name: 'Improvement')
admin = User.create(:user_name => "Zac", :email => "zac@qq.com", :first_name => "Zac", :last_name => "Chen", :activated => true, :password => "1111", :password_confirmation => "1111")
admin.role_maps.create(role_id: Role.find_by(role_name: 'administrator').id)
user = User.create(:user_name => "San", :email => "san@qq.com", :first_name => "San", :last_name => "Chen", :activated => true, :password => "1111", :password_confirmation => "1111")
user.role_maps.create(role_id: Role.find_by(role_name: 'developer').id)
