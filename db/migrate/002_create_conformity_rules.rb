class CreateConformityRules < ActiveRecord::Migration
  def change
    create_table :conformity_rules do |t|
      t.integer :project_id,        null: false
      t.string :content,            null: false

      t.timestamps
    end
  end
end
