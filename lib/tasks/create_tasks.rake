# coding: utf-8

namespace :redmine do
  namespace :email_grabber do

    desc 'Create tasks from emails'
    task :create_tasks => :environment do

      settings = Setting.find_by_name('plugin_email_grabber') ? Setting.find_by_name('plugin_email_grabber').value : ''

      equal_conformity_rules = ConformityRule.where :conformity_type => 'equal'
      contains_conformity_rules = ConformityRule.where :conformity_type => 'contains'

      Email.where('issue_created IS FALSE AND parent_message_id IS NULL').order(:id).each do |email|
        domain_name = email.from.split('@').last, project_id = ''

        [equal_conformity_rules, contains_conformity_rules].each do |rules_array|
          rules_array.each do |rule|
            if domain_name.include? rule.content
              project_id = rule.project_id
              break
            end

            break unless project_id.blank?
          end
        end

        issue = Issue.new(
          :subject        => email.subject,
          :description    => email.body,

          :tracker_id     => settings[:tracker_id],
          :author_id      => settings[:author_id],
          :assigned_to_id => settings[:assigned_to_id],

          :project_id     => project_id
        )

        if issue.save
          email.update_attributes :issue_created => true, :issue_id => issue.id
        end
      end


      Email.where('issue_created IS FALSE AND parent_message_id IS NOT NULL').order(:id).each do |email|
        parent_email = get_parent_email email.parent_message_id

        unless parent_email.blank?
          issue = parent_email.issue

          unless issue.blank?
            journal = issue.init_journal(User.find_by_id settings[:author_id])
            journal.update_attribute :notes, email.body

            if issue.save
              email.update_attribute :issue_created, true
            end
          end
        end
      end

    end

  end
end

def get_parent_email message_id
  email = Email.find_by_message_id message_id

  if email.parent_message_id.blank?
    return email
  else
    get_parent_email email.parent_message_id
  end
end