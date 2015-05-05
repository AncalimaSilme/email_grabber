class EmailsController < ApplicationController
  unloadable

  def index
    @emails = Email.all
  end

  def show
    @email = Email.find(params[:id])
  end
end
