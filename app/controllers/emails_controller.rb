class EmailsController < ApplicationController
  layout 'admin'

  def index
    @emails = Email.order("id DESC")
  end

  def show
    @email = Email.find params[:id] 
  end
end
