class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :job_number
      t.string :author
      t.text :description
      t.string :status
      t.integer :parent_task
      t.string :assignee
      t.references :task, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
