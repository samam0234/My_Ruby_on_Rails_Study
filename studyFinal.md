# studyFinal. 작은 게시판

지금까지의 진도를 한 사이트로 다시 조립합니다. `demo`는 진도가 쌓인 실습 앱이고, `project`는 `rails new`로 새로 만든 게시판입니다. 모듈 이름은 `Board`입니다.

들어 있는 것:

- 회원, 글, 댓글 모델과 마이그레이션
- ERB 화면의 글 CRUD, 댓글, 세션 로그인, 작성자만 수정·삭제
- `/api/v1` JSON, 중첩 댓글, 검색, 페이지, JWT
- CORS. `js/project`는 5180, `ts/project`는 5181에서 같은 API를 부릅니다

서버는 demo와 겹치지 않게 3001을 씁니다.

```powershell
Remove-Item Env:DEBUG -ErrorAction SilentlyContinue
$env:Path = "C:\Ruby34-x64\bin;" + $env:Path
cd project
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 3001 -b 127.0.0.1
```

`db:seed`는 `mina@example.com` / `password123`과 글 "환영합니다"를 만듭니다. 이 계정은 로컬 학습용입니다. 비밀번호 재설정, 이메일 인증, 잠금은 없습니다. Devise도 쓰지 않습니다.

`config/master.key`는 저장소에 넣지 않습니다. 클론한 뒤에는 그 키가 있어야 credentials를 읽습니다.

## 검증 결과

`project`에서 `bundle exec rails test`:

```text
44 runs, 137 assertions, 0 failures, 0 errors, 0 skips
```

`js/project`의 `node --test`는 6개 통과입니다. `ts/project`의 `npm test`는 6개 통과이고 `tsc --noEmit`도 통과입니다.

브라우저 자동화 도구는 이 환경에 없어서, 화면 클릭 대신 테스트와 HTTP 응답으로 확인합니다. `http://127.0.0.1:3001`에서 `/`, `/posts`, `/login`, `/api/v1/posts`는 200이었습니다. 목록 JSON에는 시드 글 "환영합니다"와 작성자 "미나"가 있습니다. `Origin: http://127.0.0.1:5180` preflight도 200이고 같은 origin을 돌려줍니다. `POST /api/v1/login`은 200이고 닉네임은 "미나"입니다.
