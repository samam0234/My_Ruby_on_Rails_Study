# 작은 게시판

studyFinal에서 만드는 Rails 앱입니다. 모듈 이름은 `Board`이고, 화면과 JSON API를 같이 제공합니다.

```powershell
Remove-Item Env:DEBUG -ErrorAction SilentlyContinue
$env:Path = "C:\Ruby34-x64\bin;" + $env:Path
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 3001 -b 127.0.0.1
```

샘플 계정 `mina@example.com` / `password123`은 로컬 학습용입니다. `config/master.key`는 커밋하지 않습니다.

JavaScript 클라이언트는 `js/project`(5180), TypeScript 클라이언트는 `ts/project`(5181)입니다. 둘 다 이 서버의 `/api/v1`을 부릅니다.
