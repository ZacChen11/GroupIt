class CreateAssignedTasksAssigneesJoinTable < ActiveRecord::Migration
  def change
    create_table :assigned_tasks_assignees, id: false do |t|
      t.belongs_to :task, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
    end

  end
end
