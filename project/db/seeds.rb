user = User.find_or_create_by!(email: "mina@example.com") do |record|
  record.nickname = "미나"
  record.password = "password123"
  record.password_confirmation = "password123"
end

unless user.posts.exists?(title: "환영합니다")
  user.posts.create!(title: "환영합니다", body: "작은 게시판의 첫 글입니다. 이 계정은 로컬 학습용입니다.")
end
