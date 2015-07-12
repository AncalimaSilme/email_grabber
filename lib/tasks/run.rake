namespace :redmine do
  namespace :plugin do
    namespace :email_grabber do
      desc "Get messages form email and create issues"
      task :run do
        # run get_messages raketask
        Rake::Task["redmine:plugin:email_grabber:get_messages"].invoke

        # run create_issues raketask
        Rake::Task["redmine:plugin:email_grabber:create_issues"].invoke
      end
    end
  end
end
