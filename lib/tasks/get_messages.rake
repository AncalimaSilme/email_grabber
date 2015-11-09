# coding: utf-8

require 'net/imap'
require 'net/pop'
require 'mail'

namespace :redmine do
  namespace :plugin do
    namespace :email_grabber do
      desc 'Fetching messages from server through pop3 or imap'
      task :get_messages => :environment do

        plugin_setting = Setting.find_by_name('plugin_email_grabber')
        unless plugin_setting.blank?
          plugin_settings = plugin_setting.value
          unless plugin_settings.blank?
            email_options = {
                :username => plugin_settings['username'],
                :password => plugin_settings['password'],
                :address => plugin_settings['address'],
                :enable_ssl => plugin_settings['enable_ssl'],
                :port => plugin_settings['port'],
                :protocol => plugin_settings['protocol'],
                :delete_after_receive => plugin_settings['delete_after_receive']
            }

            Mail.defaults do
              retriever_method email_options[:protocol].downcase.to_sym, {
                :address => email_options[:address],
                :port => email_options[:port],
                :user_name => email_options[:username],
                :password => email_options[:password],
                :enable_ssl => email_options[:enable_ssl]
              }
            end

            mails = Mail.find(
              :delete_after_find => email_options[:delete_after_receive],
              :count => 100,
              :keys  => ['NOT', 'SEEN']
            )

            unless mails.empty?
              mails.each do |msg|
                mail = Mail.new(msg)

                body = mail.html_part ? mail.html_part : mail.text_part
                body = mail.body if body.blank?

                email = Email.find_by_message_id mail.message_id
                email = Email.create!(
                    :message_id => mail.message_id,
                    :from => mail.from.first,
                    :subject => mail.subject,
                    :date => mail.date.to_s,
                    :body => body.decoded.force_encoding('utf-8'),
                    :parent_message_id => mail.in_reply_to
                ) unless email

                author = User.find_by_mail mail.from.first
                author = User.find_by_id plugin_settings[:author_id] if author.blank?
                author = User.find_by_id 0 if author.blank?

                mail.attachments.each do |attachment|
                  disk_directory = DateTime.now.strftime("%Y/%m")
                  disk_filename = Attachment.disk_filename(attachment.filename, disk_directory)
                  disk_file = File.join(Rails.root, "files", disk_directory.to_s, disk_filename.to_s)

                  # create directory if not exists
                  Dir.mkdir(File.join(Rails.root, "files", disk_directory.to_s)) unless Dir.exists?(File.join(Rails.root, "files", disk_directory.to_s))

                  # create file
                  begin
                    File.open(disk_file, "wb") {|f| f.write attachment.body.decoded}
                  rescue => error
                    puts "Unable to save data for #{disk_filename} because '#{error.message}'"
                  end

                  # md5
                  md5 = Digest::MD5.new
                  md5.update disk_file

                  # create attachment
                  if File.exists? disk_file
                    email.attachments.create!({
                      filename: attachment.filename,
                      disk_directory: disk_directory,
                      disk_filename: disk_filename,
                      author_id: author.id,
                      digest: md5.hexdigest,
                      content_type: Redmine::MimeType.of(disk_filename),
                      filesize: File.size(disk_file)
                    })
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

