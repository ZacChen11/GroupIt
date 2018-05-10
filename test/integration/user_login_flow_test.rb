require 'test_helper'

class UserLoginFlowTest < ActionDispatch::IntegrationTest
  test "user log in flow" do
    get login_path
    assert_response :success
    post '/login', params: { email_or_username:  "Zac", password: 1111}
    assert_response :redirect
    assert_redirected_to root_path
  end
end
