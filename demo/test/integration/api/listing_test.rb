require "test_helper"

class Api::ListingTest < ActionDispatch::IntegrationTest
  test "html search finds a title" do
    get posts_path, params: { q: "메모" }

    assert_response :success
    assert_select "a", text: "메모"
    assert_select "a", text: "첫 글", count: 0
  end

  test "api page returns one post and the total" do
    get api_v1_posts_path, params: { page: 1, per: 1 }, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal [ "메모" ], body.fetch("posts").map { |post| post["title"] }
    assert_equal 2, body.dig("meta", "total")
    assert_equal 1, body.dig("meta", "page")
  end

  test "api search matches the body" do
    get api_v1_posts_path, params: { q: "본문" }, as: :json

    titles = JSON.parse(response.body).fetch("posts").map { |post| post["title"] }
    assert_equal [ "첫 글" ], titles
  end
end
