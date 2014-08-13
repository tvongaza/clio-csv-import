class CsvDownloadController < ApplicationController
  def show
  	@params = params
  	if defined? params[:file]
    	send_file params[:file], :type=> 'text/csv'
  	end
  end
end
