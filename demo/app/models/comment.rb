class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :body, presence: true, length: { maximum: 1_000 }
end
