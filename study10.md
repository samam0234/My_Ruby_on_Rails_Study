# study10. 고급 기술 구현 5 — CORS와 브라우저 클라이언트

`js/demo`와 `ts/demo`는 Rails와 다른 포트에서 열립니다. 브라우저는 기본적으로 `http://127.0.0.1:5173`에서 `http://127.0.0.1:3000`으로의 요청을 막습니다. `rack-cors`가 `/api/*`만 엽니다.

허용 origin:

| 폴더 | 주소 |
|---|---|
| js/demo | http://127.0.0.1:5173 |
| ts/demo | http://127.0.0.1:5174 |
| js/project | http://127.0.0.1:5180 |
| ts/project | http://127.0.0.1:5181 |

`localhost`도 같은 포트로 허용합니다. 그 외 origin은 `Access-Control-Allow-Origin`을 받지 않습니다. 쿠키는 쓰지 않고 `Authorization` 헤더만 허용합니다.

클라이언트는 `POST /api/v1/login`으로 토큰을 받아 `sessionStorage`에 둡니다. 목록, 검색, 페이지, 글 작성, 상세, 댓글 작성, 내 댓글 삭제를 같은 API로 합니다. HTML 세션 화면은 그대로입니다.

## 검증 결과

`bundle exec rails test`:

```text
44 runs, 137 assertions, 0 failures, 0 errors, 0 skips
```

- `Origin: http://127.0.0.1:5173` 목록 요청은 200이고 같은 origin을 돌려줍니다.
- `http://evil.example`에는 CORS 헤더가 없습니다.
- `http://127.0.0.1:5174`의 preflight는 `authorization` 헤더를 허용합니다.

`js/demo`의 `node --test`는 6개 통과입니다. `ts/demo`의 `npm test`는 6개 통과이고 `tsc --noEmit`도 통과입니다.

다음 문서는 [studyFinal.md](studyFinal.md)입니다. 지금까지의 기능을 한 게시판 사이트로 다시 조립합니다.
