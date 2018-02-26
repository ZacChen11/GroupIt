class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :email
      t.string :first_name
      t.string :last_name
      t.float  :total_work_time, default: 0
      t.boolean :activated, default: false
      t.timestamps null: false


    end
  end
end
