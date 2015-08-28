class EmailsController < ApplicationController
  layout 'admin'

  def index
    @limit = per_page_option
    
    @emails = Email.order("id DESC")
    @email_count = @emails.size
    @email_pages = Paginator.new @email_count, @limit, params['page']
    @offset ||= @email_pages.offset
    @emailss = @emails.limit(@limit).offset(@offset)
  end

  def show
    @email = Email.find params[:id] 
  end
end