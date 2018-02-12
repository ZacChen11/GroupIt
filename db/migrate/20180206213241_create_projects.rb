class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.string :author
      t.text :description
      t.integer :parent_user
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
