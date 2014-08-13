class DeleteJobController < ApplicationController
	before_action :require_token
	
  def new
  	@heading = "Contact Import Review"
    if File.file?(Rails.root.join("tmp/successful/contacts_created.csv"))
	 		@success = CSV.open(Rails.root.join("tmp/successful/contacts_created.csv"),:headers => true ).read
	 	end
    if File.file?(Rails.root.join("tmp/unsuccessful/contacts_not_created.csv"))
	 		@non_success = CSV.open(Rails.root.join("tmp/unsuccessful/contacts_not_created.csv"),:headers => true ).read
	 	end	 	
  end
  
  def create
  	if params[:id].present?
    	person = client.contacts.find(params[:id].to_i)
    	begin
    	 if person.present?
    	  person.destroy
    	 end
    	rescue ClioClient::BadRequest
    		flash[:error] = "not successfully deleted"
    		flash.now[:error] = "not successfully deleted"
    	end	
  	end
  end

end
