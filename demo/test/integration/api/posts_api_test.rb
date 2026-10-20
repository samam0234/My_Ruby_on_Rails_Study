require "test_helper"

class Api::PostsApiTest < ActionDispatch::IntegrationTest
  test "index returns posts as json" do
    get api_v1_posts_path, as: :json

    assert_response :success
    titles = JSON.parse(response.body).fetch("posts").map { |post| post["title"] }
    assert_includes titles, posts(:hello).title
    authors = JSON.parse(response.body).fetch("posts").map { |post| post["author"] }
    assert_includes authors, "미나"
  end

  test "create requires a session" do
    post api_v1_posts_path, params: { post: { title: "API", body: "본문" } }, as: :json

    assert_response :unauthorized
  end

  test "create stores the logged in author" do
    log_in_as users(:mina)

    assert_difference -> { Post.count }, 1 do
      post api_v1_posts_path, params: { post: { title: "API", body: "본문" } }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "API", body["title"]
    assert_equal "미나", body["author"]
  end

  test "another user cannot update a post" do
    log_in_as users(:mina)
    patch api_v1_post_path(posts(:memo)), params: { post: { title: "가로챔", body: "본문" } }, as: :json

    assert_response :forbidden
    assert_equal "메모", posts(:memo).reload.title
  end
end
