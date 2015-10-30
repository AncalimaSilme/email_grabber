class RemoveConformityRuleType < ActiveRecord::Migration
  def change
    remove_column :conformity_rules, :conformity_type
  end
end