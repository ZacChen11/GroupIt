class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :author
      t.text :description
      t.integer :status
      t.integer :assignee_id
      t.references :parent_task, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
