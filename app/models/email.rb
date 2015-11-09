class Email < ActiveRecord::Base
  belongs_to :issue
  belongs_to :archive
  has_many :attachments, as: :container

  acts_as_attachable

  def project
    self.issue ? self.issue.project : nil 
  end
end

# TODO:
# - error 403 while trying download attachment