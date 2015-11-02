class Email < ActiveRecord::Base
  belongs_to :issue
  belongs_to :archive
end
