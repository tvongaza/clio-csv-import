class AuthorizationController < ApplicationController
  
  def new
   @heading = "Connect Clio Account"
  end
  
  def create
    redirect_to client.authorize_url(redirect_uri)
  end

  def show
    token = client.authorize_with_code redirect_uri, params[:code]
    if client.authorized?
      session[:access_token] = token["access_token"]
   else
      render :file => "public/401", :status => :unauthorized
   end
   redirect_to import_job_new_path
  end

  private

  def redirect_uri
   uri = URI.parse(request.url)
   uri.path = '/authorization/show'
   uri.query = nil
   uri.to_s
  end

end
