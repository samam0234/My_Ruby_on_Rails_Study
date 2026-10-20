# study5. 실습5 — 세션 로그인과 작성자 권한

지금까지는 누구나 글을 쓰고 지울 수 있었습니다. 이번 실습은 비밀번호를 해시로 저장하고, 로그인 세션으로 작성자를 고정합니다.

Notion은 인증을 "Devise 또는 직접"이라고 적습니다. 여기서는 직접 구현합니다. Devise가 대신 만들어 주는 조각을 눈으로 보기 위해서입니다.

| 우리가 만든 것 | Devise가 숨기는 이름 |
|---|---|
| `has_secure_password`, `password_digest` | `database_authenticatable` |
| `RegistrationsController` | `registerable` |
| `session[:user_id]` | `SessionsController`가 다루는 세션 |
| `require_login`, `require_author` | `authenticate_user!`, 권한 젬 |

비밀번호 재설정, 이메일 인증, 계정 잠금은 넣지 않았습니다. 그 기능이 필요해지면 Devise를 검토합니다. 원리를 모르는 채로 젬만 켜면 로그인 실패가 났을 때 고칠 곳이 안 보입니다.

## 1. 비밀번호 해시

`Gemfile`의 bcrypt를 켜고 설치했습니다.

```powershell
bundle install
bundle exec rails db:migrate
```

마이그레이션은 `users.password_digest` 컬럼 하나만 추가합니다. 비밀번호 원문은 컬럼으로 만들지 않습니다.

```ruby
class User < ApplicationRecord
  has_secure_password

  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end
```

`has_secure_password`는 `password`와 `password_confirmation`을 받아 `password_digest`에 bcrypt 해시를 넣습니다. `user.authenticate("password123")`가 맞으면 사용자 객체를, 틀리면 `false`를 돌려줍니다.

기존 개발 DB의 회원은 해시가 비어 있어서 로그인되지 않습니다. 테스트 픽스처만 알려진 비밀번호 `password123`의 해시를 가집니다. 이 값은 학습용입니다.

## 2. 가입과 로그인

```ruby
get "signup", to: "registrations#new"
post "signup", to: "registrations#create"
get "login", to: "sessions#new"
post "login", to: "sessions#create"
delete "logout", to: "sessions#destroy"
```

가입이 성공하면 `session[:user_id]`에 id를 넣고 글 목록으로 보냅니다. 로그인은 이메일을 소문자로 찾은 뒤 `authenticate`를 호출합니다. 실패하면 422로 로그인 폼을 다시 그립니다. 로그아웃은 `reset_session`으로 세션 전체를 비웁니다.

`current_user`는 세션 id로 `User`를 한 번만 찾습니다. 뷰에서도 쓰도록 `helper_method`로 공개했습니다.

Rails 로그 필터는 `:passw`로 시작하는 파라미터를 가립니다. `password`는 로그에 남지 않습니다.

## 3. 작성자만 수정

글과 댓글의 `belongs_to :user`는 이제 필수입니다. 작성은 로그인 사용자로만 합니다.

```ruby
@post = current_user.posts.build(post_params)
@comment = @post.comments.build(comment_params.merge(user: current_user))
```

`post_params`에는 `:user_id`가 없습니다. 폼에 작성자 필드를 넣어도 무시됩니다.

수정과 삭제는 작성자만 통과합니다. 다른 사용자는 상세 화면으로 돌아가고 알림을 봅니다. 화면의 수정/삭제 버튼도 작성자에게만 그립니다. 버튼을 숨기는 것만으로는 부족해서 컨트롤러가 한 번 더 검사합니다.

댓글 폼은 로그인 전에 보이지 않고, "로그인하고 댓글 남기기" 링크를 보여 줍니다.

## 4. 검증 결과

`bundle exec rails test`:

```text
26 runs, 87 assertions, 0 failures, 0 errors, 0 skips
```

확인한 흐름은 아래와 같습니다.

- 가입하면 글 목록에 닉네임이 나타납니다.
- 틀린 비밀번호는 422입니다.
- 로그인하지 않은 글 작성은 로그인 화면으로 갑니다.
- 로그인한 사용자의 글에는 그 사용자가 작성자로 저장됩니다.
- 다른 사용자는 제목을 바꾸거나 댓글을 지우지 못합니다.
- 작성자는 글을 지우면 댓글도 함께 지웁니다.

다음 문서는 [study6.md](study6.md)입니다. 같은 게시글을 JSON으로도 내보냅니다.
