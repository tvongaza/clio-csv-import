class ImportJobController < ApplicationController
  
  def new
   @heading = ".csv Selection"
  end
  
  def preview
  	@heading = "Mapping Preview"
  	CSV::Converters[:blank_to_nil] = lambda do |field|
  		field && field.empty? ? nil : field
  	end
  	CSV::HeaderConverters[:space_to_underscore] = lambda do |field|
  		field.tr(" ","_")
  	end
		@csv_arr = CSV.read(params[:csv].path)
    session[:csv_name] = params[:csv].original_filename
    File.open(Rails.root.join('tmp', 'uploads', session[:csv_name]), 'wb') do |file|
    	file.write(params[:csv].read)
  	end
  end
  
  def create
		@heading = ".csv Imported"
		arr = []
		types = {}
		params.each{|key,value| 
		if ["first_name","last_name","city","province","postal_code","country","street","phone_number","web_site","email_address","instant_messenger"].include? value
			if ["phone_number","web_site","email_address","instant_messenger"].include? value
				types["#{value} type"] = params["#{key} type"]
			end 
			arr.push(value)
		end
		}	
		if File.file?(Rails.root.join("tmp/uploads/#{session[:csv_name]}"))
	 		@csv_arr = CSV.read(Rails.root.join("tmp/uploads/#{session[:csv_name]}"),:headers => arr, :converters => [:all, :blank_to_nil] )
	  	@csv_arr.delete(0)
	  	@csv_arr.to_a.map	
	  	headers = CSV.read(Rails.root.join("tmp/uploads/#{session[:csv_name]}"))[0]
	    CSV.open(Rails.root.join("tmp/Unsuccessful/contacts_not_created.csv"), "wb") do |csv|
	    	csv << headers
	  	end
	  	headers.insert(0,"Contact Id")
      CSV.open(Rails.root.join("tmp/successful/contacts_created.csv"),"wb") do |csv|
	      csv << headers
	  	end 
	  	@csv_arr.each do |row| 
	  		contact_arr = []
	  		phone_numbers = []
	  		email_addresses = []
	  		web_sites = []
	  		instant_messengers = []
	  		addresses = []  
	  		address = {} 
	  	  @contact = row.to_hash
	  	  @contact.each{|key,value| if ["first_name","last_name"].include? key
	  	 		contact_arr.push(value)
	  	 	 end
	  	 	 }
	  	  @contact.each{|key,value| 
	  	  	if ["city","province","postal_code","country","street"].include? key
		  			address[key] = value
		  			contact_arr.push(value)
		  			@contact.delete(key)
					elsif ["phone_number"].include? key 
						if value != nil
							phone_numbers.push({"name" => types['#{key} type'],"number" => value})
						end
						contact_arr.push(value)
						@contact.delete(key)
					elsif ["email_address"].include? key 
						if value != nil
							email_addresses.push({"name" => types["#{key} type"],"address" => value})
						end
						contact_arr.push(value)
						@contact.delete(key)
					elsif ["web_site"].include? key 
						if value != nil
							web_sites.push({"name" => types["#{key} type"],"address" => value})
						end
						contact_arr.push(value)
						@contact.delete(key)
					elsif["instant_messenger"].include? key
						if value != nil
							instant_messengers.push({"name" => types["#{key} type"],"address" => value})
						end
						contact_arr.push(value)
						@contact.delete(key)
					end	
				}
				addresses.push(address)
				@contact["web_sites"] = web_sites
				@contact["phone_numbers"] = phone_numbers
				@contact["email_addresses"] = email_addresses
				@contact["instant_messengers"] = instant_messengers
				@contact["addresses"] = addresses
	  	  @contact["type"] = "Person"
	  	  person = client.contacts.new(@contact) 	  
	  	 	begin
    			person.save
    			contact_arr.insert(0,person.id)
    			CSV.open(Rails.root.join("tmp/successful/contacts_created.csv"), "a+") do |csv| 
	          csv << contact_arr
	  	  	end
  			rescue ClioClient::BadRequest
  				CSV.open(Rails.root.join("tmp/unsuccessful/contacts_not_created.csv"), "a+") do |csv|
  			    csv << contact_arr
  				end
  			end  	  
	  	  if File.file?(Rails.root.join("tmp/uploads/#{session[:csv_name]}"))
  				File.delete(Rails.root.join("tmp/uploads/#{session[:csv_name]}"))
  			end	 	  
	  	end
	  end  
	end

end
