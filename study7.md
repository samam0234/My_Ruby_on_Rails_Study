# study7. 고급 기술 구현 2 — 중첩 댓글 API

댓글은 글에 속합니다. URL도 글 아래에 둡니다. Django의 nested router와 같은 자리입니다.

```ruby
resources :posts do
  resources :comments, only: %i[index create destroy]
end
```

이 블록은 `namespace :api / :v1` 안에 있습니다. 주소는 아래와 같습니다.

| HTTP | 경로 | 하는 일 |
|---|---|---|
| GET | /api/v1/posts/:post_id | 글과 댓글 목록 |
| GET | /api/v1/posts/:post_id/comments | 댓글만 |
| POST | /api/v1/posts/:post_id/comments | 댓글 작성 |
| DELETE | /api/v1/posts/:post_id/comments/:id | 댓글 삭제 |

글 목록에는 댓글을 넣지 않습니다. 목록이 댓글 수만큼 커지지 않게 하려는 선택입니다. 상세 응답에만 `comments` 배열이 붙습니다.

```json
{
  "id": 1,
  "title": "첫 글",
  "author": "미나",
  "comments": [
    { "id": 1, "body": "첫 댓글입니다", "author": "미나" }
  ]
}
```

작성자는 세션의 `current_user`입니다. 요청 바디의 `user_id`는 permit하지 않습니다. 다른 사람의 댓글 삭제는 403입니다.

## 검증 결과

`bundle exec rails test test/integration/api/comments_api_test.rb`:

```text
3 runs, 9 assertions, 0 failures, 0 errors, 0 skips
```

- 글 상세 JSON에 픽스처 댓글 본문이 있습니다.
- 준으로 로그인하고 댓글을 만들면 201이고 `author`는 "준"입니다.
- 준이 미나의 댓글을 지우면 403이고 댓글은 남습니다.

다음 문서는 [study8.md](study8.md)입니다. 목록에 검색과 페이지를 넣습니다.
