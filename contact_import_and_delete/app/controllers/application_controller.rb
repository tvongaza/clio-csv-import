class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  private
  
  def client
  	if @client.nil?
  		client_id = APP_CONFIG['client_id']
  		client_secret = APP_CONFIG['client_secret']
  		access_token = session[:access_token]

  		@client = ClioClient::Session.new({client_id: client_id, client_secret: client_secret})
  	end
  	@client.access_token = session[:access_token] if session[:access_token].present?
  	@client
  end
  
  def require_token
  	unless session[:access_token].present?
  		redirect_to root_path
  	end
  end

end
