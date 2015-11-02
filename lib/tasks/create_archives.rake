# coding: utf-8

namespace :redmine do
  namespace :plugin do
    namespace :email_grabber do

      desc "Create archive for email messages by last month"
      task :create_archive_for_last_month => :environment do
        date = Time.now.to_date - 1.month
        archive = Archive.find { |a| a.month == date.month && a.year == date.year } || Archive.create!(month: date.month, year: date.year)
        Email.where(date: date.beginning_of_day..date.end_of_day, archive: nil).update_all archive_id: archive.id
      end

      desc "Create archive list"
      task :create_archive_list => :environment do
        Email.where(archive_id: nil).each do |email|
          date = email.date.to_date
          archive = Archive.find { |a| a.month == date.month && a.year == date.year } || Archive.create!(month: date.month, year: date.year)
          email.update_attribute :archive_id, archive.id
        end
      end

    end
  end
end