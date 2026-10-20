# study6. 고급 기술 구현 1 — 게시글 JSON API

HTML 화면은 그대로 두고, 같은 `Post`를 JSON으로도 내보냅니다. Django REST Framework의 첫 APIView에 해당하는 단계입니다. 화면용 JavaScript는 아직 호출하지 않습니다. 응답 모양을 먼저 고정합니다.

## 1. 주소를 나눈다

브라우저 폼은 `/posts`를 쓰고, 프로그램은 `/api/v1/posts`를 씁니다. 버전이 경로에 있으면 나중에 응답 모양을 바꿔도 예전 클라이언트를 남겨 둘 수 있습니다.

```ruby
namespace :api do
  namespace :v1 do
    resources :posts, only: %i[index show create update destroy]
  end
end
```

`new`와 `edit`는 HTML 폼 전용이라 API에 없습니다.

## 2. API 컨트롤러

`Api::V1::BaseController`는 CSRF 검사를 끄고, 로그인이 없으면 302 대신 401 JSON을 돌려줍니다. 세션 쿠키는 HTML 로그인과 같은 `session[:user_id]`를 읽습니다. 토큰은 study9에서 추가합니다.

작성은 `current_user.posts.build`만 허용합니다. `user_id`는 permit 목록에 없습니다. 다른 사람의 글을 수정하거나 지우면 403입니다.

응답 필드는 Jbuilder partial 한 곳이 정합니다.

```ruby
json.id post.id
json.title post.title
json.body post.body
json.author post.user&.nickname
json.created_at post.created_at
```

목록은 `{ "posts": [ ... ] }`입니다. 한 건은 그 객체를 바로 반환합니다.

## 3. 검증 결과

`bundle exec rails test test/integration/api/posts_api_test.rb`:

```text
4 runs, 13 assertions, 0 failures, 0 errors, 0 skips
```

확인한 내용은 아래와 같습니다.

- `GET /api/v1/posts`는 로그인 없이 200이고, 픽스처 글 제목과 작성자 "미나"가 들어 있습니다.
- 세션 없이 `POST /api/v1/posts`는 401입니다.
- 미나로 로그인한 뒤 만들면 201이고 `author`는 "미나"입니다.
- 미나가 준의 글을 수정하면 403이고 제목은 그대로입니다.

다음 문서는 [study7.md](study7.md)입니다. 댓글을 글 아래 자원으로 JSON에 넣습니다.
