# study2. 실습2 — 모델과 마이그레이션

게시판을 만들기 전에 테이블부터 만듭니다. Django에서 `models.py`를 적고 `makemigrations`를 하는 자리입니다. Rails에서는 생성기가 마이그레이션 초안을 만들고, 적용 명령은 `rails db:migrate`입니다.

이 단계의 모델은 세 개입니다.

| 모델 | 테이블 | 컬럼 |
|---|---|---|
| User | users | email, nickname |
| Post | posts | title, body |
| Comment | comments | post_id, body |

비밀번호 컬럼은 아직 없습니다. 인증은 study5에서 마이그레이션을 하나 더 추가합니다. 회원과 글의 관계 선언(`has_many`)도 study4로 미룹니다. 지금은 컬럼과 검증, 댓글이 글을 가리키는 외래 키까지입니다.

## 1. 생성 명령

`demo/`에서 실행했습니다.

```powershell
bundle exec rails generate model User email:string nickname:string
bundle exec rails generate model Post title:string body:text
bundle exec rails generate model Comment post:references body:text
```

생성기는 모델, 마이그레이션, 픽스처, 모델 테스트를 함께 만듭니다. 만든 직후의 컬럼은 `null: false`가 아니므로, **migrate 전에** 마이그레이션을 고쳤습니다. 이미 적용한 파일은 고치지 않고 다음 마이그레이션을 추가하는 것이 원칙입니다. 아직 어떤 환경에도 적용하지 않았다면 초안을 고치고 적용해도 됩니다.

```ruby
create_table :users do |t|
  t.string :email, null: false
  t.string :nickname, null: false
  t.timestamps
end
add_index :users, :email, unique: true
```

`post:references`는 `comments.post_id`와 인덱스, `posts`로의 외래 키를 만듭니다. 컬럼 이름이 `_id`로 끝나는 것이 Active Record의 약속입니다.

적용과 현재 스키마 확인입니다.

```powershell
bundle exec rails db:migrate
```

`db/schema.rb`의 버전은 `2026_10_20_171238`입니다. 이 파일은 결과물이므로 직접 수정하지 않습니다.

## 2. 모델 검증

`User`는 이메일을 저장 전에 다듬습니다. `normalizes`는 검증보다 먼저 공백과 대소문자를 정리합니다.

```ruby
class User < ApplicationRecord
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :nickname, presence: true, length: { maximum: 30 }
end
```

`Post`는 제목과 본문이 있어야 하고, 제목은 120자를 넘지 못합니다. `Comment`는 본문이 있어야 하고 글에 속합니다.

```ruby
class Comment < ApplicationRecord
  belongs_to :post

  validates :body, presence: true
end
```

`belongs_to :post`는 `post_id`가 비면 저장하지 않겠다는 선언입니다. 반대편 `Post.has_many :comments`는 study4에서 붙입니다. 한쪽만 있어도 `comment.post`는 동작합니다.

Django의 `ForeignKey(Post, on_delete=...)`와 달리, 지울 때 댓글을 같이 지울지는 아직 정하지 않았습니다. `dependent: :destroy`도 study4입니다.

## 3. 픽스처

테스트 데이터는 `test/fixtures`에 둡니다. 테스트가 시작될 때 이 YAML이 테스트 DB에 들어갑니다.

```yaml
# test/fixtures/comments.yml
on_hello:
  post: hello
  body: 첫 댓글입니다
```

`post: hello`는 `posts.yml`의 `hello` 레코드를 가리킵니다. id를 숫자로 적지 않아도 됩니다.

## 4. 검증 결과

`bundle exec rails db:migrate`가 세 마이그레이션을 적용했습니다.

`bundle exec rails test`:

```text
8 runs, 13 assertions, 0 failures, 0 errors, 0 skips
```

모델 테스트가 확인한 내용은 아래와 같습니다.

- `New@Example.com `처럼 공백과 대문자가 섞인 이메일은 `new@example.com`으로 저장됩니다.
- 같은 이메일은 두 번 저장되지 않습니다.
- 닉네임이나 글 제목이 없으면 저장되지 않습니다.
- 픽스처 댓글의 `post`는 픽스처 글 `hello`입니다.

화면은 아직 목록을 그리지 않습니다. 다음 문서 [study3.md](study3.md)에서 이 `Post`로 CRUD 화면을 만듭니다.
