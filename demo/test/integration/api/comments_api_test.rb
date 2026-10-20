require "test_helper"

class Api::CommentsApiTest < ActionDispatch::IntegrationTest
  test "post show includes comments" do
    get api_v1_post_path(posts(:hello)), as: :json

    assert_response :success
    bodies = JSON.parse(response.body).fetch("comments").map { |comment| comment["body"] }
    assert_includes bodies, comments(:on_hello).body
  end

  test "create comment belongs to the logged in user" do
    log_in_as users(:jun)

    assert_difference -> { posts(:hello).comments.count }, 1 do
      post api_v1_post_comments_path(posts(:hello)), params: { comment: { body: "API 댓글" } }, as: :json
    end

    assert_response :created
    assert_equal "준", JSON.parse(response.body).fetch("author")
  end

  test "another user cannot delete the comment" do
    log_in_as users(:jun)
    delete api_v1_post_comment_path(posts(:hello), comments(:on_hello)), as: :json

    assert_response :forbidden
    assert Comment.exists?(comments(:on_hello).id)
  end
end
