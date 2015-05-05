class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :from, null: false
      t.string :theme, null: false
      t.string :body, null: false

      t.boolean :task_created, default: false

      t.timestamps
    end
  end
end
