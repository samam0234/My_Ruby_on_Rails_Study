# study9. 고급 기술 구현 4 — JWT 로그인

HTML 화면은 study5의 세션을 그대로 씁니다. JSON API는 쿠키 없이 호출할 수 있게 Bearer 토큰을 받습니다. Devise는 쓰지 않습니다. 토큰 발급은 `jwt` gem과 `ApiToken`이 담당합니다.

```ruby
class ApiToken
  ALGORITHM = "HS256"
  TTL = 12.hours

  def self.secret
    ENV["JWT_SECRET"].presence || Rails.application.secret_key_base
  end
end
```

비밀값은 환경 변수 `JWT_SECRET`이 있으면 그것을 쓰고, 없으면 Rails `secret_key_base`를 씁니다. `master.key`는 커밋하지 않습니다.

| HTTP | 경로 | 하는 일 |
|---|---|---|
| POST | /api/v1/login | 이메일·비밀번호가 맞으면 `{ token, user }` |
| 그 외 쓰기 | /api/v1/posts ... | `Authorization: Bearer <token>` 또는 기존 세션 |

`Authorization` 헤더가 있으면 세션은 보지 않습니다. 헤더가 없을 때만 study5 쿠키로 로그인합니다. API 로그인은 `session[:user_id]`를 넣지 않습니다. HTML `POST /login`은 여전히 리다이렉트입니다.

토큰 payload는 `sub`(회원 id)와 `exp`(12시간)입니다. 서명이 틀리거나 만료되면 401 `{ "error": "로그인이 필요합니다." }`입니다.

## 검증 결과

`bundle exec rails test`:

```text
40 runs, 129 assertions, 0 failures, 0 errors, 0 skips
```

- `mina@example.com` / `password123` 로그인은 200이고 `user.nickname`은 "미나"입니다. 세션 id는 비어 있습니다.
- 그 토큰으로 글을 만들면 201이고 작성자는 "미나"입니다.
- 비밀번호가 틀리거나 `exp`가 과거인 토큰은 401입니다.

다음 문서는 [study10.md](study10.md)입니다. 브라우저 클라이언트가 API를 부를 수 있게 CORS를 엽니다.
