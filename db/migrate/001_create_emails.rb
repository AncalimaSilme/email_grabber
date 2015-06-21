class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.integer :issue_id

      t.string  :message_id,          null: false
      t.string  :from,                null: false
      t.string  :subject,             null: false
      t.text    :body,                null: false
      t.string  :date

      t.boolean :task_created,        default: false
      t.string  :parent_message_id

      t.timestamps
    end

    add_index :emails, :message_id, :unique => true
  end
end
