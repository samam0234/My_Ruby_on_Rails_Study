class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validates :body, presence: true, length: { maximum: 5_000 }

  scope :search, ->(query) {
    cleaned = query.to_s.strip
    next all if cleaned.empty?

    term = "%#{sanitize_sql_like(cleaned)}%"
    where("title LIKE :term OR body LIKE :term", term: term)
  }

  def self.catalog(query:, page:, per:)
    page = [ page.to_i, 1 ].max
    per = per.to_i
    per = 10 if per < 1
    per = 50 if per > 50
    scope = includes(:user).search(query).order(created_at: :desc)
    [ scope.offset((page - 1) * per).limit(per), scope.count, page, per ]
  end
end
