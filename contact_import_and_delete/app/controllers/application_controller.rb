class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  private
  
  def client
    if @client.nil?
      client_id = APP_CONFIG['client_id']
      client_secret = APP_CONFIG['client_secret']

      @client = ClioClient::Session.new({client_id: client_id, client_secret: client_secret})
    end
    @client.access_token = session[:access_token] if session[:access_token].present?
    @client
  end
  
  def require_token
    unless session[:access_token].present?
      redirect_to authorization_new_path
    end
  end

  def get_user_directory(subfolder = nil)
    Rails.root.join("tmp/client_folders/#{session[:access_token].to_s}/#{subfolder.to_s}")
  end
  
  def check_client_folders
    unless Dir.exists?(get_user_directory())
      Dir.mkdir(get_user_directory())
      Dir.mkdir(get_user_directory("uploads"))
      Dir.mkdir(get_user_directory("successful_imports"))
      Dir.mkdir(get_user_directory("unsuccessful_imports"))
      Dir.mkdir(get_user_directory("successful_import_undos"))
      Dir.mkdir(get_user_directory("unsuccessful_import_undos"))
    end
  end

  def get_client_file(folder)
    check_client_folders
    client_file = File.new(get_user_directory("#{folder}/#{session[:csv_name]}"))
  end

  def create_client_file(client_file,folder)
   check_client_folders
   if client_file.present?
     new_file = File.open(get_user_directory("#{folder}/#{session[:csv_name]}"),"wb") do |file|
       file.write(client_file.read)
     end
   else
    new_file = File.new(get_user_directory("#{folder}/#{session[:csv_name]}"),"wb")
   end
   new_file
  end

end
