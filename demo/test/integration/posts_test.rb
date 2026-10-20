require "test_helper"

class PostsTest < ActionDispatch::IntegrationTest
  test "index lists posts" do
    get posts_path

    assert_response :success
    assert_select "a", text: posts(:hello).title
  end

  test "missing post is not found" do
    get post_path(0)

    assert_response :not_found
  end

  test "create rejects a blank title" do
    assert_no_difference -> { Post.count } do
      post posts_path, params: { post: { title: "", body: "본문" } }
    end

    assert_response :unprocessable_entity
  end

  test "create redirects to the new post" do
    assert_difference -> { Post.count }, 1 do
      post posts_path, params: { post: { title: "새 글", body: "내용" } }
    end

    created = Post.order(:id).last
    assert_redirected_to created
    follow_redirect!
    assert_select "h1", "새 글"
  end

  test "update changes the title" do
    patch post_path(posts(:memo)), params: { post: { title: "고친 메모", body: "본문" } }

    assert_redirected_to posts(:memo)
    assert_equal "고친 메모", posts(:memo).reload.title
  end

  test "destroy removes the post and its comments" do
    comment_id = comments(:on_hello).id

    assert_difference -> { Post.count }, -1 do
      assert_difference -> { Comment.count }, -1 do
        delete post_path(posts(:hello))
      end
    end

    assert_redirected_to posts_path
    assert_not Comment.exists?(comment_id)
  end
end
