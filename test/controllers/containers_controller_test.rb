require 'test_helper'

class ContainersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get containers_new_url
    assert_response :success
  end

end
