require 'test_helper'

class ImportControllerTest < ActionController::TestCase
  test "should get get_csv" do
    get :get_csv
    assert_response :success
  end

end
