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

  def destroy
    @email = Email.find params[:id]
    @email.destroy
    redirect_to emails_path
  end

  def archive
    @email = Email.find params[:email_id]

    if @email.archive_id.blank?
      @date = @email.date.to_date
      @archive = Archive.find { |a| a.month == @date.month && a.year == @date.year } || Archive.create!(month: @date.month, year: @date.year)
      @email.update_attribute :archive_id, @archive.id
    else
      @email.update_attribute :archive_id, nil
    end

    redirect_to emails_path
  end
end

# TODO:
# - redirect with params for actions: destroy and archive