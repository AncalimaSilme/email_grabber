class RemoveIssueCreated < ActiveRecord::Migration
  def change
    remove_column :emails, :issue_created
  end
end