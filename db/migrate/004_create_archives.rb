class CreateArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.string  :name,  null: false
      t.integer :month, null: false
      t.integer :year,  null: false
      
      t.timestamps
    end

    # archive references
    add_column :emails, :archive_id, :integer

    # archive indexes
    add_index :archives, :name
  end
end
