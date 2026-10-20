require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "root renders the welcome page" do
    get root_path

    assert_response :success
    assert_select "h1", "Rails 실습에 오신 것을 환영합니다"
  end

  test "health check responds" do
    get rails_health_check_path

    assert_response :success
  end
end
