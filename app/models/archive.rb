class Archive < ActiveRecord::Base
  has_many :emails

  before_save :create_name

  private

    def create_name
      self.name = "#{self.month}/#{self.year}" if self.name.blank?
    end
end