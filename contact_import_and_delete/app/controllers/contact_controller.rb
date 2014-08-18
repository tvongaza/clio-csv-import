class ContactController < ApplicationController
  before_action :require_token

  def destroy
  	person = client.contacts.find(params[:id].to_i)
    begin
      person.destroy
      render :json => { :success => "successfully deleted" }, :status => 200 
    rescue ClioClient::BadRequest,NoMethodError
      render :json => { :error => "not successfully deleted" }, :status => 400 
    end
  end
end
