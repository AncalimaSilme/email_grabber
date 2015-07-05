# coding: utf-8

namespace :redmine do
  namespace :email_grabber do

    desc 'Create tasks from emails'
    task :create_issues => :environment do

      settings = Setting.find_by_name('plugin_email_grabber') ? Setting.find_by_name('plugin_email_grabber').value : ''

      equal_conformity_rules = ConformityRule.where :conformity_type => 'equal'
      contains_conformity_rules = ConformityRule.where :conformity_type => 'contains'

      Email.where('issue_created IS FALSE AND parent_message_id IS NULL').order(:id).each do |email|
        domain_name, project_id = email.from.split('@').last,  ''

        [equal_conformity_rules, contains_conformity_rules].each do |rules_array|
          rules_array.each do |rule|
            if domain_name.include? rule.content
              project_id = rule.project_id
              break
            end

            break unless project_id.blank?
          end
        end

        unless is_html email.body
          issue = Issue.new(
            :subject        => email.subject,
            :description    => printable_body(email.body),

            :tracker_id     => settings[:tracker_id],
            :author_id      => settings[:author_id],
            :assigned_to_id => settings[:assigned_to_id],

            :project_id     => project_id
          )

          if issue.save
            email.update_attributes :issue_created => true, :issue_id => issue.id
          end
        end
      end


      Email.where('issue_created IS FALSE AND parent_message_id IS NOT NULL').order(:id).each do |email|
        parent_email = get_parent_email email.parent_message_id

        unless parent_email.blank?
          issue = parent_email.issue

          unless issue.blank?
            journal = issue.init_journal(User.find_by_id settings[:author_id])
            journal.update_attribute :notes, printable_body(email.body)

            if issue.save
              email.update_attribute :issue_created, true
            end
          end
        end
      end

    end

  end
end

# get parent message for message
def get_parent_email message_id
  email = Email.find_by_message_id message_id

  if email.parent_message_id.blank?
    return email
  else
    get_parent_email email.parent_message_id
  end
end

# clear body from answered messages
def printable_body body
  clean_body, index = body, body.index(/\d+.\d+.\d+ \d+:\d+, .+:/)

  unless index.blank?
      clean_body.slice!(index, clean_body.size)
  end

  clean_body
end

def is_html body
  ['<table', '<div', '<span', '<ul', '<body'].any? { |html_tag| body.include? html_tag }
end
