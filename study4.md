# study4. 실습4 — Active Record 관계

study3에서 댓글이 달린 글은 외래 키 때문에 삭제가 거절됐습니다. 이번 실습은 그 관계를 Ruby 선언으로 완성합니다. 회원은 글을 여러 개 가지고, 글은 댓글을 여러 개 가집니다.

## 1. 마이그레이션

작성자 컬럼은 테이블을 만든 뒤에 추가합니다. 이미 적용한 `create_posts`를 고치지 않습니다.

```powershell
bundle exec rails generate migration AddUserToPostsAndComments
bundle exec rails db:migrate
```

```ruby
add_reference :posts, :user, null: true, foreign_key: true
add_reference :comments, :user, null: true, foreign_key: true
```

`add_reference :posts, :user`는 `posts.user_id`와 인덱스를 만듭니다. 기존 글이 있을 수 있어 컬럼은 비어 있어도 됩니다. study5에서 새 글은 로그인 사용자를 반드시 넣습니다.

## 2. 양쪽 선언

외래 키만으로는 `user.posts`가 생기지 않습니다. 모델에 방향을 적습니다.

```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
end

class Post < ApplicationRecord
  belongs_to :user, optional: true
  has_many :comments, dependent: :destroy
end

class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
end
```

| 선언 | 의미 | Django에서 가까운 것 |
|---|---|---|
| `belongs_to :user` | 이 레코드가 `user_id`를 가진다 | `ForeignKey(User)` |
| `has_many :posts` | 반대쪽에서 목록을 꺼낸다 | `related_name`으로 역참조 |
| `dependent: :destroy` | 부모를 지울 때 자식 `destroy`를 호출한다 | `on_delete=models.CASCADE`와 비슷하지만 콜백이 돈다 |
| `optional: true` | `user_id`가 비어 있어도 된다 | `null=True` |

`dependent: :destroy`는 SQL `ON DELETE CASCADE`와 다릅니다. Rails가 댓글 객체를 하나씩 지웁니다. 댓글 모델에 콜백을 붙여도 실행됩니다. 데이터베이스 외래 키는 여전히 "없는 글을 가리키면 안 된다"를 지킵니다.

댓글 본문은 1,000자, 글 본문은 5,000자까지로 검증을 더했습니다.

## 3. 화면에서 관계를 쓰기

목록은 작성자 닉네임을 보여 줍니다. `includes(:user)`로 글을 가져올 때 작성자도 함께 읽어, 글 개수만큼 사용자 조회가 반복되지 않게 했습니다.

상세 화면은 댓글 목록과 작성 폼을 붙입니다. 라우트는 글을 부모로 둡니다.

```ruby
resources :posts do
  resources :comments, only: %i[create destroy]
end
```

댓글 작성 주소는 `POST /posts/:post_id/comments`입니다. 폼은 `form_with model: [@post, Comment.new]`입니다. 배열을 넘기면 Rails가 중첩 경로를 만듭니다.

지우는 주소는 `DELETE /posts/:post_id/comments/:id`입니다. `button_to`가 `_method=delete` 폼을 만듭니다.

## 4. study3 테스트가 바뀐 이유

댓글이 달린 글을 지울 때 예외가 나던 테스트는 제거했습니다. 지금은 글을 지우면 댓글 수도 같이 줄어들어야 합니다. 관계가 생기기 전의 실패를 관계 이후에도 기대해 두면 테스트가 옛 버그를 보호하게 됩니다.

## 5. 검증 결과

`bundle exec rails test`:

```text
19 runs, 57 assertions, 0 failures, 0 errors, 0 skips
```

개발 DB에 회원 "미나", 글 "관계 확인", 댓글 "첫 관계 댓글"을 넣고 `GET /posts/1`을 요청했습니다. 응답은 200이었고, 작성자 "미나", 댓글 본문, `POST /posts/1/comments/1`로 가는 삭제 폼, 댓글 작성 폼이 들어 있었습니다.

다음 문서는 [study5.md](study5.md)입니다. 비밀번호와 세션으로 작성자를 로그인 사용자에게 고정합니다.
