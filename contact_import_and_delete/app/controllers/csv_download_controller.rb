class CsvDownloadController < ApplicationController
  before_action :require_token

  def show
    raise "Invalid file" unless params[:file] == "import_success" || "import_failure" || "undo_success" || "undo_failure"
    if params[:file] == "import_success"
     file_path = get_client_file("successful_imports")
    elsif params[:file] == "import_failure"
    	file_path = get_client_file("unsuccessful_imports")
    elsif params[:file] == "undo_success"
    	file_path = get_client_file("successful_import_undos")
    elsif params[:file] == "undo_failure"
    	file_path = get_client_file("unsuccessful_import_undos")
    end
    send_file file_path, type: 'text/csv'
  end

end


