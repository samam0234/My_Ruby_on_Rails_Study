require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email and rejects a duplicate" do
    user = User.create!(email: "  New@Example.com ", nickname: "새", password: "password123")

    assert_equal "new@example.com", user.email
    duplicate = User.new(email: "new@example.com", nickname: "다른", password: "password123")
    assert_not duplicate.valid?
    assert duplicate.errors[:email].any?
  end

  test "requires a nickname" do
    user = User.new(email: "noname@example.com", nickname: "")

    assert_not user.valid?
  end
end
