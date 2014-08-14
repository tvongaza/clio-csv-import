class AuthorizationController < ApplicationController
  
  def new
   @heading = "Connect Clio Account"
  end
  
  def create
  	redirect_to client.authorize_url(redirect_uri)
  end

	def show
		@heading = "Authenticated"
    token = client.authorize_with_code redirect_uri, params[:code]
  	if client.authorized?
   		session[:access_token] = token["access_token"]
 	 else
    	halt 401, "Not authorized\n"
 	 end
	end

  private

  def redirect_uri
   uri = URI.parse(request.url)
   uri.path = '/authorization/show'
   uri.query = nil
   uri.to_s
  end

end
