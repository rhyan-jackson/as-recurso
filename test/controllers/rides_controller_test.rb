require "test_helper"

class RidesControllerTest < ActionDispatch::IntegrationTest
  test "should get confirm" do
    get rides_confirm_url
    assert_response :success
  end

  test "should get create" do
    get rides_create_url
    assert_response :success
  end
end
