class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :email
      t.string :first_name
      t.string :last_name
      t.boolean :is_deleted, default: false
      t.boolean :activated, default: false
      t.timestamps null: false


    end
  end
end
