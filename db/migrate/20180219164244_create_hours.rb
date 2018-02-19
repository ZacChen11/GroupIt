class CreateHours < ActiveRecord::Migration
  def change
    create_table :hours do |t|
      t.integer :work_time
      t.references :task, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
