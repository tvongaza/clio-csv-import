class HomeController < ApplicationController
  
  def new
   @heading = ""
  end
  
  def redirect_uri
   uri = URI.parse(request.url)
   uri.path = '/home/callback'
   uri.query = nil
   uri.to_s
  end
  
  def auth
  	redirect_to client.authorize_url(redirect_uri)
  end

	def callback
		@heading = "Authenticated"
    token = client.authorize_with_code redirect_uri, params[:code]
  	if client.authorized?
   		session[:access_token] = token["access_token"]
 	 else
    	halt 401, "Not authorized\n"
 	 end
	end

end
