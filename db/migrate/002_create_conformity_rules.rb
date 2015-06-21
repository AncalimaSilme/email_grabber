class CreateConformityRules < ActiveRecord::Migration
  def change
    create_table :conformity_rules do |t|
      t.integer :project_id,        null: false
      t.string :content,            null: false
      t.string :conformity_type,    null: false

      t.timestamps
    end
  end
end
