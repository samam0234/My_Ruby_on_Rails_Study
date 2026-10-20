require "test_helper"

class Api::CorsTest < ActionDispatch::IntegrationTest
  test "js demo origin can read the api" do
    get api_v1_posts_path, headers: { "Origin" => "http://127.0.0.1:5173" }, as: :json

    assert_response :success
    assert_equal "http://127.0.0.1:5173", response.headers["Access-Control-Allow-Origin"]
  end

  test "ts project origin is allowed" do
    get api_v1_posts_path, headers: { "Origin" => "http://127.0.0.1:5181" }, as: :json

    assert_equal "http://127.0.0.1:5181", response.headers["Access-Control-Allow-Origin"]
  end

  test "an unknown origin is not reflected" do
    get api_v1_posts_path, headers: { "Origin" => "http://evil.example" }, as: :json

    assert_nil response.headers["Access-Control-Allow-Origin"]
  end

  test "preflight allows the authorization header" do
    process :options, api_v1_posts_path, headers: {
      "Origin" => "http://127.0.0.1:5174",
      "Access-Control-Request-Method" => "POST",
      "Access-Control-Request-Headers" => "authorization,content-type"
    }

    assert_response :success
    assert_equal "http://127.0.0.1:5174", response.headers["Access-Control-Allow-Origin"]
    assert_includes response.headers["Access-Control-Allow-Headers"].to_s.downcase, "authorization"
  end
end
