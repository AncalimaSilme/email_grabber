# coding: utf-8

Redmine::Plugin.register :email_grabber do
  name 'Email Grabber plugin'
  author 'Alexander Kazachkin'
  description 'This is a plugin for Redmine. It is help you get email messages and create issues'
  version '0.0.3'
  url 'https://github.com/AncalimaSilme/email_grabber'

  menu :admin_menu, :email, { :controller => 'emails', :action => 'index' }, :caption => :emails_page_title
  menu :admin_menu, :conformity_rules, { :controller => 'conformity_rules', :action => 'index' }, :caption => :conformity_rules_page_title

  settings  :partial => 'settings/email_grabber_settings', :default => {'empty' => true}
end
