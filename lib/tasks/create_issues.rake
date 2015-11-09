# coding: utf-8

require 'nokogiri'
require 'mail'

namespace :redmine do
  namespace :plugin do
    namespace :email_grabber do

      desc 'Create tasks from emails'
      task :create_issues => :environment do

        settings = Setting.find_by_name('plugin_email_grabber') ? Setting.find_by_name('plugin_email_grabber').value : ''

        Mail.defaults do
          delivery_method :smtp, ActionMailer::Base.smtp_settings
        end

        Email.where(issue_created: false, parent_message_id: nil, archive_id: nil).order(:id).each do |email|
          domain_name, project_id = email.from.split('@').last,  ''
          author = User.where(type: "User", mail: email.from)[0]

          ConformityRule.all.each do |rule|
            if domain_name.include? rule.content
              project_id = rule.project_id
              break
            end
          end

          project = Project.find_by_id project_id
          unless project.blank?
            unless author && allowed(author, project)
              author = User.find_by_id settings[:author_id]
            end

            issue = Issue.new(
              :subject        => email.subject,
              :description    => printable_body(email.body),
              :tracker_id     => settings[:tracker_id],
              :author_id      => author ? author.id : settings[:author_id],
              :assigned_to_id => settings[:assigned_to_id],
              :project_id     => project.id
            )

            if issue.save
              email.attachments.each do |attachment|
                issue.attachments.create!({
                  filename: attachment.filename,
                  disk_directory: attachment.disk_directory,
                  disk_filename: attachment.disk_filename,
                  author_id: attachment.author_id,
                  digest: attachment.digest,
                  content_type: attachment.content_type,
                  filesize: attachment.filesize
                })
              end if email.attachments.any?

              # Mail.deliver do
              #   protocol = Setting.find_by_name(:protocol).try(:value)
              #   hostname = Setting.find_by_name(:host_name).try(:value)
              #   conformity_bcc = settings["confirmation_bcc"]

              #   from          ActionMailer::Base.smtp_settings[:user_name]
              #   to            email.from
              #   in_reply_to   email.message_id
              #   subject       "Re: " + email.subject
              #   body          "Здравствуйте!\n" + 
              #                 "Ваш запрос зарегистрирован в системе учета задач под номером #{issue.id}.\n\n" +
              #                 "#{protocol ? protocol : 'http'}://#{hostname ? hostname : 'localhost:3000'}/issues/#{issue.id}"

              #   unless conformity_bcc.blank?
              #     bcc conformity_bcc.split(",").map { |address| address.strip }
              #   end
                              
              # end          
              
              email.update_attributes :issue_created => true, :issue_id => issue.id
            end
          end
        end


        Email.where(issue_created: false, archive_id: nil).where('parent_message_id IS NOT NULL').order(:id).each do |email|
          parent_email = get_parent_email email.parent_message_id
          author = User.where(type: "User", mail: email.from)[0]

          unless parent_email.blank?
            issue = parent_email.issue

            unless issue.blank?
              unless author && allowed(author, issue.project)
                author = User.find_by_id settings[:author_id]
              end

              journal = issue.init_journal author
              journal.notes = printable_body(email.body) unless email.body.blank?
              journal.save!

              email.attachments.each do |attachment|
                issue_attachment = issue.attachments.create!({
                  filename: attachment.filename,
                  disk_directory: attachment.disk_directory,
                  disk_filename: attachment.disk_filename,
                  author_id: attachment.author_id,
                  digest: attachment.digest,
                  content_type: attachment.content_type,
                  filesize: attachment.filesize
                })
              end if email.attachments.any?

              if issue.save
                email.update_attributes :issue_created => true, :issue_id => issue.id
              end
            end
          end
        end

      end

    end
  end
end

# check permissions
def allowed user, project
  return true if project.is_public || project.users.include?(user)
  false
end

# get parent message for message
def get_parent_email message_id
  email = Email.find_by_message_id message_id
  if email
    if email.parent_message_id.blank?
      return email
    else
      get_parent_email email.parent_message_id
    end
  end
end

# clear body from answered messages
def printable_body body
  clean_body = body

  if is_html body
    clean_body = cleaning_html clean_body
    clean_body = cleaning_nokogiri Nokogiri::HTML(body)
    clean_body = cleaning_string clean_body.text
  end

  index = clean_body.index(/((\d{2} [а-яА-Яa-zA-z]{3,7}(.| ) \d{4}(| )[годаyear]{1,4}.)|(\d{2}.\d{2}.\d{2,4}))(,|)([ вin]{1,3}|)\d{1,2}:\d{2}(,|) .{5,75}:/)
  clean_body.slice!(index, clean_body.size) unless index.blank?

   return clean_body
end

def is_html body
  ['<table', '<div', '<span', '<ul', '<body'].any? { |html_tag| body.include? html_tag }
end

def cleaning_html string
  # br to \n
  string.gsub!("<br>", "\n")

  return string
end

def cleaning_nokogiri string
  # delete gmail reply
  string.css('.gmail_extra .gmail_quote').remove
  
  # delete js and css 
  string.css('script, link, style').each { |node| node.remove }

  return string
end

def cleaning_string string
  new_string, old_string = "", string.gsub("\t", "")

  last_newline = nil
  old_string.each_line do |line|
    line.strip!

    if !line.blank? || (line.blank? && last_newline == false)
      new_string << line + "\n"
    end

    last_newline = line.blank?
  end

  return new_string
end