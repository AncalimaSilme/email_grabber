# coding: utf-8

Redmine::Plugin.register :email_grabber do
  name 'Email Grabber plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :email, { :controller => 'emails', :action => 'index' }, :caption => :emails_page_title
  menu :admin_menu, :conformity_rules, { :controller => 'conformity_rules', :action => 'index' }, :caption => :conformity_rules_page_title

  settings  :partial => 'settings/email_grabber_settings', :default => {'empty' => true}
end