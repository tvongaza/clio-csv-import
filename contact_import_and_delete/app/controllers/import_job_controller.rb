class ImportJobController < ApplicationController
  before_action :require_token
  
  def new
   @heading = ".csv Selection"
  end
  
  def create
    @heading = ".csv Imported"
    parse_and_create_file(params)
    create_contacts_through_api(params)
    redirect_to delete_job_new_path
  end

  def preview
    @heading = "Mapping Preview"
    raise "no file given" unless params[:csv].present?
    @csv_arr = CSV.read(params[:csv].path)
    session[:csv_name] = "#{Time.now.getutc.to_i}_#{params[:csv].original_filename}"
    create_client_file(params[:csv],"uploads")
  end  
  
  private 
  
  def parse_and_create_file(params)
      headers = CSV.read(get_client_file("uploads"))[0]
      CSV.open(create_client_file(nil,"unsuccessful_imports"),"wb") do |csv|
        csv << headers
      end
      headers.insert(0,"Contact Id")
      CSV.open(create_client_file(nil,"successful_imports"),"wb") do |csv|
        csv << headers
      end  
  end

  def get_headers(params)
    headers = []
    group_counter = {
      "phone_number" => 0,
      "web_site" => 0,
      "email_address" => 0,
      "instant_messenger" => 0
    }
    params.each{|key,value| 
    if ["first_name","last_name","title","city","province","postal_code","country","street","phone_number","web_site","email_address","instant_messenger"].include? value
      if (headers.include? value) && (["phone_number","web_site","email_address","instant_messenger"].include? value)
        group_counter[value] = group_counter[value] + 1
        value = "#{value}_#{group_counter[value]}"
      end
      headers.push(value)
    end
    }
    headers
  end

  def create_contacts_through_api(params)
    CSV::Converters[:blank_to_nil] = lambda do |field| #converts all blank entries in csv to nil 
      field && field.empty? ? nil : field
    end
    import_successes = []
    import_failures = []
    csv_arr = CSV.read(get_client_file("uploads"),:headers => get_headers(params), :converters => [:all, :blank_to_nil] )
    csv_arr.delete(0) #csv_arr of type CSV::Table 
    csv_arr.each do |row| 
        contact_arr = []
        phone_numbers = []
        email_addresses = []
        web_sites = []
        instant_messengers = []
        addresses = []  
        address = {} 
        contact = row.to_hash
        contact.each{|key,value| 
          if ["first_name","last_name","title"].include? key
            contact_arr.push(value)
          elsif ["city","province","postal_code","country","street"].include? key
            address[key] = value
            contact_arr.push(value)
            contact.delete(key)
          elsif key.include? "phone_number"
            if value != nil
              phone_numbers.push({"name" => "Work","number" => value})
            end
            contact_arr.push(value)
            contact.delete(key)
          elsif key.include? "email_address"
            if value != nil
              email_addresses.push({"name" => "Work","address" => value})
            end
            contact_arr.push(value)
            contact.delete(key)
          elsif key.include? "web_site" 
            if value != nil
              web_sites.push({"name" => "Work","address" => value})
            end
            contact_arr.push(value)
            contact.delete(key)
          elsif key.include? "instant_messenger"
            if value != nil
              instant_messengers.push({"name" => "Work","address" => value})
            end
            contact_arr.push(value)
            contact.delete(key)
          end 
        }
        addresses.push(address)
        contact["web_sites"] = web_sites
        contact["phone_numbers"] = phone_numbers
        contact["email_addresses"] = email_addresses
        contact["instant_messengers"] = instant_messengers
        contact["addresses"] = addresses
        contact["type"] = "Person"
        person = client.contacts.new(contact)   
        begin
          person.save
          contact_arr.insert(0,person.id)
          import_successes.push(contact_arr)
        rescue ClioClient::BadRequest
          import_failures.push(contact_arr)
        end         
      end
      create_csv_results(import_successes,import_failures) 
  end
  
  def create_csv_results(import_successes,import_failures)
    CSV.open(get_client_file("successful_imports"), "a+") do |csv| 
     import_successes.each do |row|
       csv << row
     end
    end
    CSV.open(get_client_file("unsuccessful_imports"), "a+") do |csv|
      import_failures.each do |row|
        csv << row
      end
    end
  end

end
