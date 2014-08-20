class DeleteJobController < ApplicationController
  before_action :require_token
  
  def new
    @heading = "Contact Import Review"
    @success = CSV.read(get_client_file("successful_imports"),:headers => true)    
    @failure = CSV.read(get_client_file("unsuccessful_imports"),:headers => true)  
  end

  def create
    @heading = "Import Undo"
    contacts_to_delete = parse_file(params[:csv]) #array of contacts to be deleted
    @success_results, @failure_results = delete_contacts_through_api(contacts_to_delete)
  end

  private
  
  def parse_file(file)
    contacts_to_delete = CSV.read(file.path,return_headers:false)#assuming that the client_id is in the first column of the csv so no need to parse headers
    contacts_to_delete
  end

  def delete_contacts_through_api(contacts_to_delete)
    create_client_file(nil,"successful_import_undos")
    create_client_file(nil,"unsuccessful_import_undos")
    contacts_to_delete.each do |contact|
      person = client.contacts.find(contact[0].to_i)#assuming that the client_id is in the first column of the csv
      begin
        person.destroy
        CSV.open(get_client_file("successful_import_undos"), "a+") do |csv| 
              csv << contact
        end
      rescue ClioClient::BadRequest, NoMethodError
        CSV.open(get_client_file("unsuccessful_import_undos"), "a+") do |csv| 
              csv << contact
        end
      end
    end
    success_results = get_client_file("successful_import_undos")
    failure_results = get_client_file("unsuccessful_import_undos")
    return success_results, failure_results
  end

end

