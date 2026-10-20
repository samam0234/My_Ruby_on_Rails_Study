class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 120 }
  validates :body, presence: true
end
