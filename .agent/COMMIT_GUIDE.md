# 커밋 가이드라인

study 문서 기반 학습 진행 내용을 커밋할 때 지켜야 할 규칙입니다.

## 1. 커밋 대상 확인 순서

1. `study0.md`, `study1.md`, `study2.md`, ... 번호 순서대로 문서를 확인합니다.
2. 각 문서 안에서도 위에서 아래(섹션 순서)대로 진행 상황을 파악합니다.
3. 문서 내용에 대응하는 실습 코드 변경 사항을 진도와 매칭합니다.
   - study1~10: `demo/`. 화면 실습이 있으면 `js/demo`, `ts/demo`도 같은 진도입니다.
   - studyFinal: `project/`, `js/project`, `ts/project`.

## 2. 커밋 단위 (진도 파트별 분리)

- 하나의 커밋 = 하나의 학습 진도 파트.
- 예시:
  - `study0.md` 추가 (개념 정리, 코드 변경 없음) → 커밋 1개
  - `study1.md` 진행분 + `demo/` 최초 생성, `js/demo`·`ts/demo` 첫 화면 → 커밋 1개
  - `study2.md` 진행분 + 모델/마이그레이션 → 커밋 1개
- 서로 다른 study 파일의 내용을 한 커밋에 섞지 않습니다.
- JavaScript와 TypeScript는 같은 진도의 화면이면 한 커밋에 함께 넣습니다. 내용이 크면 JS 화면 → TS 화면 순으로 세부 커밋으로 더 나눌 수 있습니다.

## 3. 커밋 메시지 형식

```
<type>: <한글 설명>
```

- `type`(prefix)은 **영어**, Conventional Commits 스타일을 사용합니다.
- 한글 설명은 무엇을 했는지 간결하고 명확하게 씁니다.

### 사용 가능한 type

| type | 용도 |
|---|---|
| feat | 새로운 기능/코드 추가 |
| fix | 버그 수정 |
| docs | study*.md 등 문서만 변경 |
| refactor | 동작 변화 없는 코드 구조 개선 |
| chore | 빌드 설정, 의존성 등 잡무성 변경 |
| test | 테스트 코드 추가/수정 |
| style | 포맷팅 등 코드 스타일 변경 |

### 예시

```
chore: 에이전트 인수인계 문서를 Rails 저장소 기준으로 수정
docs: study0 Rails 기초이론 정리
feat: study1 Rails 프로젝트 생성 및 첫 화면 실습
feat: study2 모델 설계 및 마이그레이션
feat: studyFinal 미니 게시판 프로젝트 구현
```

## 4. 커밋 순서

- study 번호가 낮은 순서대로 먼저 커밋합니다 (`study0` → `study1` → `study2` → ...).
- 새로운 `studyN.md`가 추가되고 그에 대응하는 코드가 구현되면, 같은 방식으로 이어서 커밋합니다.

## 5. 커밋 전 체크리스트

- [ ] 어떤 study 문서/파트에 대응하는 변경인지 확인했는가
- [ ] 관련 없는 변경 사항이 섞여 있지 않은가
- [ ] 커밋 메시지가 `type: 한글설명` 형식을 따르는가
- [ ] `master.key`, `.env`, SQLite 파일, `node_modules`, `log/`, `tmp/`가 빠졌는가
