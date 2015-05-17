# coding: utf-8

require 'net/imap'
require 'net/pop'
require 'mail'

namespace :redmine do
  namespace :email_grabber do
    desc 'Fetching messages from server through pop3 or imap'
    task :get_mails => :environment do

      plugin_settings = Setting.find_by_name('plugin_email_grabber').try(:value)
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
          retriever_method email_options[:protocol].downcase.to_sym, { :address      => email_options[:address],
                                                                       :port         => email_options[:port],
                                                                       :user_name    => email_options[:username],
                                                                       :password     => email_options[:password],
                                                                       :enable_ssl   => email_options[:enable_ssl]
                                                                   }
        end

        mails = Mail.find(:delete_after_find    => email_options[:delete_after_receive],
                          :count                => 100,
                          :keys                 => ['NOT', 'SEEN'])

        unless mails.empty?
          mails.each do |msg|
            mail = Mail.new(msg)

            body = mail.html_part ? mail.html_part : mail.text_part
            body = mail.body if body.blank?

            Email.create!(
                :message_id     => mail.message_id,
                :from           => mail.from.first,
                :subject        => mail.subject,
                :date           => mail.date.to_s,
                :body           => body.decoded.force_encoding('utf-8')
            )
          end
        end
      end

    end
  end
end