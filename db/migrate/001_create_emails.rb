class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string  :message_id,          null: false
      t.string  :from,                null: false
      t.string  :subject,             null: false
      t.text    :body,                null: false
      t.string  :date,                null: false

      t.boolean :task_created,        default: false
      t.string  :parent_message_id
    end

    add_index :emails, :message_id, :unique => true
  end
end
