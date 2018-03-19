class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :status
      t.string :assignment_status
      t.integer :assignment_confirmed_user_id
      t.boolean :deleted, default: false
      t.references :parent_task, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :task_type, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
