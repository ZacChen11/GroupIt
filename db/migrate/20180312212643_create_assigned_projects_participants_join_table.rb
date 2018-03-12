class CreateAssignedProjectsParticipantsJoinTable < ActiveRecord::Migration
  def change
    create_table :assigned_projects_participants, id: false do |t|
      t.references :assigned_project, index: true, foreign_key: true
      t.references :participant, index: true, foreign_key: true
    end

  end
end
