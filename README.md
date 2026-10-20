# Ruby on Rails 학습

Notion 페이지 [Ruby on Rails](https://app.notion.com/p/3fcd7dec5e2e816dba83e4c93c0a011c)의 방향대로 만든 학습 저장소입니다. Convention over Configuration으로 CRUD를 만들고, Django와 비교하면서 읽습니다.

문서는 `study0.md`부터 `study10.md`, 마지막에 `studyFinal.md` 순서입니다.

| 폴더 | 하는 일 | 주소 |
|---|---|---|
| `demo/` | study1~10이 쌓인 Rails 앱. 모듈 이름 `RailsStudy` | http://127.0.0.1:3000 |
| `project/` | studyFinal 작은 게시판. 모듈 이름 `Board` | http://127.0.0.1:3001 |
| `js/demo/` | demo API를 부르는 JavaScript | http://127.0.0.1:5173 |
| `ts/demo/` | 같은 화면의 TypeScript | http://127.0.0.1:5174 |
| `js/project/` | project API를 부르는 JavaScript | http://127.0.0.1:5180 |
| `ts/project/` | 같은 화면의 TypeScript | http://127.0.0.1:5181 |

JS와 TS는 Rails 코드를 수정하지 않습니다. 각자 폴더에서 따로 실행합니다.

## 실행

Windows에서는 Ruby가 `C:\Ruby34-x64\bin`에 있습니다. `DEBUG` 환경 변수가 남아 있으면 `rbs` 네이티브 빌드가 실패하므로 지웁니다.

```powershell
Remove-Item Env:DEBUG -ErrorAction SilentlyContinue
$env:Path = "C:\Ruby34-x64\bin;" + $env:Path
cd demo
bundle install
bin/rails db:prepare
bin/rails server -p 3000 -b 127.0.0.1
```

`project`는 같은 순서이고 포트만 3001입니다. 샘플 글이 필요하면 `bin/rails db:seed`를 합니다.

```powershell
cd js/demo
npm start
```

```powershell
cd ts/demo
npm install
npm run dev
```

`js/project`와 `ts/project`도 각 폴더에서 같은 명령입니다. 포트는 패키지 설정에 들어 있습니다.

## 이 저장소에서 만든 것

- ERB 게시판: 글 CRUD, 댓글, 세션 로그인, 작성자만 수정·삭제
- JSON API: `/api/v1`, 중첩 댓글, 검색, 페이지
- API 로그인 JWT. HTML은 세션을 유지합니다
- `rack-cors`로 위 클라이언트 포트만 허용

샘플 계정 `mina@example.com` / `password123`은 로컬 학습용입니다. 비밀번호 재설정, 이메일 인증, 계정 잠금은 없고 Devise도 쓰지 않습니다.

`config/master.key`, SQLite 파일, `node_modules`, `log/`, `tmp/`는 커밋하지 않습니다. 클론한 뒤에는 각 Rails 앱의 `master.key`가 있어야 credentials를 읽습니다.
