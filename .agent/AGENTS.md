# 에이전트 공통 가이드라인 (인수인계 문서)

이 문서는 이 저장소에서 작업하는 모든 AI 에이전트(Claude, Grok, Codex 등)가 **공통으로** 지켜야 할 규칙을 정리한 인수인계 문서입니다.
`.claude/`, `.grok/`, `.codex/` 폴더의 에이전트별 문서는 이 문서를 기본으로 삼고, 도구별 특이사항만 추가로 기술합니다.

## 1. 저장소 개요

- Ruby on Rails 학습 기록 저장소입니다. 순서는 이론 → 기초 실습 → 고급 기술 → 응용 프로젝트입니다.
- 학습 목표의 기준은 Notion 페이지 [Ruby on Rails](https://app.notion.com/p/3fcd7dec5e2e816dba83e4c93c0a011c)입니다. Django MTV와 비교하면서 Convention over Configuration을 익힙니다.
- 루트의 학습 문서는 `study0.md` ~ `study10.md`, `studyFinal.md` 순서로 진행됩니다. (숫자가 클수록 최신 진도)
  - `study0.md`: Ruby on Rails 기초 이론
  - `study1.md`: 프로젝트 생성 방법 및 명령어, 실습1
  - `study2.md` ~ `study5.md`: 실습2 ~ 실습5
  - `study6.md` ~ `study10.md`: 고급 기술 구현 1 ~ 5
  - `studyFinal.md`: 지금까지 배운 것을 응용한 미니 게시판 웹사이트
- 서버는 Rails입니다. JavaScript와 TypeScript는 그 API를 부르는 화면이고, 서로 독립이라 각자 작업할 수 있습니다.
  - `demo/`: study1~study10. 한 단계씩 쌓이는 Rails 앱입니다.
  - `project/`: `studyFinal.md`에 대응하는 Rails 미니 게시판입니다.
  - `js/demo/`: study1~study10의 JavaScript 화면입니다. Rails 코드를 덮어쓰지 않습니다.
  - `js/project/`: `studyFinal.md`의 JavaScript 게시판 화면입니다.
  - `ts/demo/`: 같은 실습을 TypeScript로 작성한 화면입니다.
  - `ts/project/`: `studyFinal.md`의 TypeScript 게시판 화면입니다.
- 공통 주제는 **게시판 + 회원**입니다. 처음에는 ERB 템플릿(MVC)으로 만들고, 뒤로 갈수록 JSON API와 별도 JS/TS 화면으로 확장합니다.

## 2. 작업 전 확인 사항

- 새 작업을 시작하기 전에 `studyN.md` 파일들을 번호 순서대로 확인하여 지금까지의 학습 진도와 맥락을 파악합니다.
- 실습 코드가 study 문서 설명과 어긋나지 않는지 확인합니다. study1~10은 `demo/`와, 화면이 있는 진도는 `js/demo`·`ts/demo`입니다. studyFinal은 `project/`, `js/project`, `ts/project`입니다.
- 새 studyN.md 문서를 추가/수정할 때는 이전 study 문서와 이어지는 흐름을 유지합니다.
- Rails 코드는 현재 저장소의 Rails 버전과 SQLite를 기준으로 합니다. 인증은 세션(`has_secure_password`)과 API용 JWT를 직접 구현합니다. Devise는 비교 설명용이며 기본 의존성으로 넣지 않습니다.
- JS와 TS는 **같은 화면 동작을 서로 다른 언어로** 작성합니다. 주소, 상태 코드, JSON 모양은 Rails API와 같아야 합니다. 한쪽을 고치면 다른 쪽과 대응하는 study 문서도 확인합니다.

## 3. 커밋 규칙

- 커밋 관련 규칙은 [COMMIT_GUIDE.md](./COMMIT_GUIDE.md) 문서를 따릅니다.

## 4. 언어 규칙

- 문서 내용, 커밋 설명: 한글
- 커밋 타입(prefix), 코드, 식별자, 파일명: 영어

## 5. 에이전트별 문서

- Claude: [.claude/CLAUDE.md](../.claude/CLAUDE.md)
- Grok: [.grok/GROK.md](../.grok/GROK.md)
- Codex: [.codex/AGENTS.md](../.codex/AGENTS.md)

## 6. 인수인계 원칙

- 작업을 마칠 때는 다음 에이전트/세션이 이어받을 수 있도록 변경 내용과 다음 단계 후보를 간단히 남깁니다.
- 불확실한 결정은 추측하지 말고 study 문서 내용을 근거로 삼습니다.
- 이 문서나 커밋 가이드에 없는 새로운 컨벤션이 필요해지면, 추측해서 각자 다르게 처리하지 말고 이 문서를 먼저 갱신합니다.

## 7. 현재 진행 현황

- 학습 문서와 실습 코드 작성 전입니다. 폴더 역할만 위 구조로 확정했습니다.
- `config/master.key`, `node_modules`, SQLite 파일, `log/`, `tmp/`는 커밋하지 않습니다.

### 다음 단계 후보

- `study0.md`부터 번호 순서대로 문서와 실습 코드를 추가합니다.
