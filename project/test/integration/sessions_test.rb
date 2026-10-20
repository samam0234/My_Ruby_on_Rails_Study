require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  test "sign up logs the user in" do
    assert_difference -> { User.count }, 1 do
      post signup_path, params: {
        user: {
          email: "new@example.com",
          nickname: "새",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to posts_path
    follow_redirect!
    assert_select "span", "새"
  end

  test "login rejects a wrong password" do
    post login_path, params: { email: users(:mina).email, password: "nope" }

    assert_response :unprocessable_entity
  end

  test "login and logout" do
    log_in_as users(:mina)
    assert_redirected_to posts_path

    delete logout_path
    assert_redirected_to root_path
  end
end
