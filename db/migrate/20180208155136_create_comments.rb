class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :body
      t.boolean :edit, default: false
      t.references :user, index: true, foreign_key: true
      t.references :task, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
