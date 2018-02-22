class CreateRoleMaps < ActiveRecord::Migration
  def change
    create_table :role_maps do |t|
      t.references :role, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
