class EmailsController < ApplicationController
  layout 'admin'

  def index
    @emails = Email.order("id DESC")

    # filtering emails
    if !params[:archive].blank? || !params[:from].blank? || !params[:subject].blank?
      @emails = @emails.where archive_id: params[:archive] unless params[:archive].blank?
      @emails = @emails.where Email.arel_table[:subject].matches("%#{params[:subject]}%") unless params[:subject].blank?
      @emails = @emails.where Email.arel_table[:from].matches("%#{params[:from]}%")  unless params[:from].blank?
    else
      @emails = @emails.where(archive_id: nil)
    end

    # pagination
    @limit = per_page_option
    @email_count = @emails.size
    @email_pages = Paginator.new @email_count, @limit, params['page']
    @offset ||= @email_pages.offset
    @emailss = @emails.limit(@limit).offset(@offset)
  end

  def show
    @email = Email.find params[:id] 
  end
end