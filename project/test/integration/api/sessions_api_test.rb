require "test_helper"

class Api::SessionsApiTest < ActionDispatch::IntegrationTest
  test "login returns a bearer token" do
    post api_v1_login_path, params: { email: "mina@example.com", password: "password123" }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert body["token"].present?
    assert_equal "미나", body.dig("user", "nickname")
    assert_nil session[:user_id]
  end

  test "wrong password is unauthorized" do
    post api_v1_login_path, params: { email: "mina@example.com", password: "nope" }, as: :json

    assert_response :unauthorized
  end

  test "bearer token can create a post" do
    post api_v1_login_path, params: { email: "mina@example.com", password: "password123" }, as: :json
    token = JSON.parse(response.body).fetch("token")

    assert_difference -> { Post.count }, 1 do
      post api_v1_posts_path,
        params: { post: { title: "토큰 글", body: "본문" } },
        headers: { "Authorization" => "Bearer #{token}" },
        as: :json
    end

    assert_response :created
    assert_equal "미나", JSON.parse(response.body).fetch("author")
  end

  test "expired token is unauthorized" do
    token = JWT.encode({ "sub" => users(:mina).id, "exp" => 1.hour.ago.to_i }, ApiToken.secret, "HS256")

    post api_v1_posts_path,
      params: { post: { title: "만료", body: "본문" } },
      headers: { "Authorization" => "Bearer #{token}" },
      as: :json

    assert_response :unauthorized
    assert_equal 2, Post.count
  end
end
