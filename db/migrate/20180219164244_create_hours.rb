class CreateHours < ActiveRecord::Migration
  def change
    create_table :hours do |t|
      t.float :work_time
      t.text :explanation
      t.boolean :is_deleted, default: false
      t.references :task, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
