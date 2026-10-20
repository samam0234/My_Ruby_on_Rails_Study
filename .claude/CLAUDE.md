# Claude 전용 인수인계 문서

공통 규칙은 [../.agent/AGENTS.md](../.agent/AGENTS.md) 및 [../.agent/COMMIT_GUIDE.md](../.agent/COMMIT_GUIDE.md)를 먼저 확인하고 따릅니다.
이 문서에는 Claude를 사용할 때만 해당하는 특이사항을 기록합니다.

## Claude 관련 참고 사항

- 이 환경은 Windows(Git Bash + PowerShell)입니다. 아래는 작업 중 겪은 도구 관련 메모입니다.
  - Bash 도구에 아주 긴 heredoc(여러 파일을 한 번에 생성)을 넣으면 파싱 오류가 날 수 있습니다. 파일 생성은 Write 도구를 쓰는 편이 안전합니다.
  - Git Bash 경로(`/c/Users/...`)는 Windows용 `python`이 읽지 못합니다. Python 스크립트에는 `C:\...` 형식의 경로를 넘깁니다.
  - git이 줄바꿈(LF→CRLF) 경고를 출력하지만 동작에는 영향이 없습니다.
  - `npm install <패키지>` 는 `--no-save`로 임시 설치한 패키지를 정리(prune)할 수 있습니다. 임시 도구는 저장소 밖에서 쓰거나 설치 순서를 주의합니다.
  - 개발 서버를 백그라운드로 띄웠다면 작업 후 해당 포트의 프로세스만 종료합니다.
