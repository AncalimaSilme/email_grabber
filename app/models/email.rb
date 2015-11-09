class Email < ActiveRecord::Base
  belongs_to :issue
  belongs_to :archive
  has_many :attachments, as: :container

  # acts_as_attachable

  before_destroy :attachment_destroy

  def project
    issue ? issue.project : nil 
  end

  def attachments_visible?(user)
    user.admin?
  end

  private

    def attachment_destroy
      self.attachments.each do |attachment|
        attachment.destroy if Attachment.where(:digits => attachment.digits).size == 1
      end
    end
end