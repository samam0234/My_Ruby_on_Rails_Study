# study8. 고급 기술 구현 3 — 검색과 페이지

목록이 길어지면 한 번에 다 내려주지 않습니다. HTML 게시판과 JSON API가 같은 `Post.catalog`를 씁니다. 화면과 API가 다른 정렬을 만들지 않으려는 선택입니다.

```ruby
def self.catalog(query:, page:, per:)
  page = [ page.to_i, 1 ].max
  per = per.to_i
  per = 10 if per < 1
  per = 50 if per > 50
  scope = includes(:user).search(query).order(created_at: :desc)
  [ scope.offset((page - 1) * per).limit(per), scope.count, page, per ]
end
```

| 쿼리 | 기본 | 동작 |
|---|---|---|
| `q` | 없음 | 제목 또는 본문을 SQLite `LIKE`로 찾습니다. 공백이면 전체입니다. |
| `page` | 1 | 1보다 작으면 1입니다. |
| `per` | 10 | 1 미만은 10, 50을 넘으면 50입니다. |

정렬은 `created_at` 내림차순입니다. 최신 글이 앞에 옵니다.

API 목록 응답에는 `meta`가 붙습니다. 댓글은 여전히 목록에 없고 상세에만 있습니다.

```json
{
  "posts": [{ "id": 2, "title": "메모", "author": "준" }],
  "meta": { "page": 1, "per": 1, "total": 2 }
}
```

HTML `/posts`에는 검색 폼과, 글이 한 페이지를 넘을 때만 이전/다음 링크가 있습니다.

`%`와 `_`는 `sanitize_sql_like`로 이스케이프합니다. 사용자가 넣은 와일드카드가 전체 검색이 되지 않게 하려는 것입니다.

## 검증 결과

`bundle exec rails test`:

```text
36 runs, 118 assertions, 0 failures, 0 errors, 0 skips
```

- `q=메모` HTML 목록에는 "메모"만 있고 "첫 글"은 없습니다.
- `page=1&per=1` JSON은 글 1개와 `meta.total` 2입니다. 픽스처에서 더 새로운 글은 "메모"입니다.
- `q=본문` JSON은 본문에 그 단어가 있는 "첫 글"만 돌려줍니다.

다음 문서는 [study9.md](study9.md)입니다. API 로그인에 JWT를 붙입니다.
