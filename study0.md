# study0. Ruby on Rails 기초이론

Notion 페이지 [Ruby on Rails](https://app.notion.com/p/3fcd7dec5e2e816dba83e4c93c0a011c)의 방향은 이렇습니다. Ruby 기반의 풀피처 프레임워크로, Convention over Configuration을 써서 CRUD를 빠르게 만들고, Django와 비교하면서 MVC를 익힙니다.

이 문서는 명령을 치기 전에 지도를 그리는 단계입니다. 코드는 다음 문서부터 `demo/`에 쌓입니다.

## 1. Rails란?

Ruby on Rails(줄여서 Rails)는 Ruby로 웹 애플리케이션을 만드는 풀스택 프레임워크입니다. 라우팅, ORM, 템플릿, 마이그레이션, 테스트, 보안 기본값이 한 세트로 들어 있습니다.

두 문장이 설계의 중심입니다.

- **Convention over Configuration.** 이름과 위치를 약속대로 두면 설정 파일을 따로 쓰지 않습니다. `PostsController`는 `app/controllers/posts_controller.rb`에 있고, `Post` 모델은 `posts` 테이블을 봅니다.
- **DRY (Don't Repeat Yourself).** 같은 규칙을 컨트롤러, 뷰, 설정에 반복해서 적지 않습니다. `resources :posts` 한 줄이 일곱 개 REST 경로를 만듭니다.

Django도 "배터리가 포함된" 풀피처 프레임워크입니다. 차이는 취향이 아니라 기본 자세입니다. Rails는 약속을 따르면 코드가 짧아지고, Django는 설정과 앱 경계를 더 명시적으로 드러냅니다.

### 다른 프레임워크와 비교

| 관심사 | Rails | Django | Express |
|---|---|---|---|
| 언어 | Ruby | Python | JavaScript |
| 구조 이름 | MVC | MTV | 미들웨어 + 라우터 |
| 화면 | 기본은 ERB 템플릿 | 기본은 Django 템플릿 | 직접 선택 |
| ORM | Active Record | Django ORM | 없음 (Prisma 등을 추가) |
| CRUD 시작 | `rails generate scaffold` | 제네릭 뷰 + 폼 | 라우트를 직접 작성 |
| 관리 화면 | 없음. 필요하면 따로 만듦 | Admin이 기본 포함 | 없음 |
| 설정 태도 | 약속이 기본값 | 설정이 코드에 보임 | 조립이 기본값 |

이 저장소는 Express에서 손으로 붙이던 일을 Rails 약속 안에서는 어떻게 한 줄이 되는지, Django 제네릭 뷰와 Admin이 Rails에서는 어디에 대응하는지를 같이 봅니다.

## 2. MVC와 Django MTV

Rails의 MVC는 역할이 세 갈래입니다.

| Rails | 하는 일 | Django에서 가까운 것 |
|---|---|---|
| Model | 데이터, 검증, 관계. Active Record 클래스 | Model |
| View | HTML/JSON으로 응답을 그리는 템플릿 | Template |
| Controller | 요청을 받아 모델을 부르고 뷰를 고름 | View |

이름이 겹쳐서 헷갈리는 지점이 하나 있습니다. Django의 View는 Rails의 Controller에 가깝습니다. Django의 Template이 Rails의 View입니다. "Django 뷰를 어디에 둘까?"를 Rails에서 찾으면 `app/controllers`입니다.

요청 하나는 이렇게 흐릅니다.

```
브라우저
  → 라우터 (config/routes.rb)
  → 컨트롤러 액션 (app/controllers)
  → 모델 (app/models, 필요하면 DB)
  → 뷰 (app/views, HTML 또는 JSON)
  → HTTP 응답
```

예를 들어 `GET /posts/3`은 `resources :posts` 약속에 따라 `PostsController#show`로 갑니다. `show`는 `Post.find(3)`을 하고 `app/views/posts/show.html.erb`를 렌더합니다. 이 연결을 컨트롤러마다 설정 파일로 적지 않는 것이 Convention over Configuration입니다.

## 3. 요청이 지나가는 계층

Rails도 요청이 컨트롤러에 닿기 전에 미들웨어 스택을 지납니다. Express에서 직접 끼우던 일이 기본으로 들어 있는 경우가 많습니다.

- **라우터.** URL과 HTTP 메서드를 컨트롤러 액션으로 바꿉니다.
- **CSRF 보호.** 폼 제출에 위조 방지 토큰이 없으면 거절합니다. `form_with`가 토큰을 넣어 줍니다.
- **쿠키 / 세션.** 로그인 상태를 서버 세션에 둡니다. 뒤의 API 단계는 세션 대신 JWT를 비교합니다.
- **Strong Parameters.** 컨트롤러가 허가한 키만 모델에 넘깁니다. 클라이언트가 `admin: true` 같은 필드를 끼워 넣는 것을 막습니다.

액션 이름은 REST를 따릅니다.

| 액션 | HTTP | 경로 예 | 하는 일 |
|---|---|---|---|
| index | GET | /posts | 목록 |
| show | GET | /posts/:id | 한 건 |
| new | GET | /posts/new | 작성 폼 |
| create | POST | /posts | 저장 |
| edit | GET | /posts/:id/edit | 수정 폼 |
| update | PATCH/PUT | /posts/:id | 수정 반영 |
| destroy | DELETE | /posts/:id | 삭제 |

`resources :posts`가 이 일곱 줄을 만듭니다. 중첩이 필요하면 `resources :posts do resources :comments end`처럼 자원 아래에 자원을 둡니다. 댓글은 게시글에 속하므로 URL도 `/posts/:post_id/comments`가 됩니다.

## 4. Active Record와 마이그레이션

Active Record는 테이블 한 줄을 Ruby 객체로 다룹니다. `Post.create(title: "안녕")`은 INSERT이고, `Post.find(1)`은 SELECT입니다.

스키마는 모델 파일에 적지 않습니다. **마이그레이션** 파일에 변경을 적고 `rails db:migrate`로 적용합니다. 파일 이름은 타임스탬프라서 순서가 남습니다. 이미 적용한 마이그레이션을 고치는 대신 새 마이그레이션을 추가하는 것이 약속입니다.

관계는 모델에 선언합니다.

```ruby
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
end
```

`belongs_to :user`는 `posts.user_id`가 있다는 약속입니다. 외래 키 컬럼 이름은 `_id`로 끝납니다. Django의 `ForeignKey`와 같은 일을 선언 위치로 나눕니다. Rails는 "하나" 쪽(`belongs_to`)과 "여러 개" 쪽(`has_many`)을 양쪽 모델에 적습니다.

## 5. 프로젝트 디렉터리 지도

`rails new`가 만드는 트리에서 이 과정에서 자주 여는 곳만 적습니다.

```
demo/
├── app/
│   ├── controllers/    # 요청을 받는 클래스
│   ├── models/         # Active Record
│   └── views/          # ERB, Jbuilder
├── config/
│   ├── routes.rb       # URL 약속
│   └── database.yml    # SQLite 파일 위치
├── db/
│   ├── migrate/        # 스키마 변경 기록
│   └── schema.rb       # 현재 스키마의 결과 (직접 수정하지 않음)
├── test/               # Minitest
├── Gemfile             # gem 의존성
└── bin/rails           # 서버, 생성기, 콘솔 진입점
```

Django의 프로젝트/앱 분리와 다릅니다. Rails도 `rails generate`로 이름 공간을 나누지만, 이 저장소의 `demo`는 학습용으로 앱을 잘게 쪼개지 않고 `app/` 아래에서 모델 단위로 파일을 나눕니다. 회원은 `User`, 게시글은 `Post`, 댓글은 `Comment`입니다.

## 6. 화면은 두 갈래다

Rails 기본 화면은 서버가 ERB로 HTML을 보냅니다. 폼, 로그인, 목록이 여기에 해당합니다. 브라우저에 보내는 JavaScript는 나중 단계에서 Importmap으로 조금만 얹습니다. 핵심 흐름은 서버 렌더링입니다.

저장소에는 그와 별도로 `js/`, `ts/` 폴더가 있습니다. 여기는 Rails 코드를 수정하지 않고, Rails가 열어 주는 JSON API를 각자의 언어로 호출하는 화면입니다.

- `js/demo`, `ts/demo`는 study 실습 화면입니다. 같은 API를 다른 언어로 부릅니다.
- `js/project`, `ts/project`는 최종 게시판 화면입니다.
- 두 폴더는 의존성을 공유하지 않습니다. 한쪽에서 `npm install`을 해도 다른 쪽이 바뀌지 않습니다.

Django 학습에서 템플릿을 먼저 하고 DRF와 CORS를 나중에 한 것과 같은 순서입니다. study1~5는 ERB, study6부터 JSON, study10에서 별도 화면이 API에 접속합니다.

## 7. 이 커리큘럼의 로드맵

| 문서 | 내용 | Notion 학습 목표 |
|---|---|---|
| study0 | 기초이론. MVC, 약속, Active Record | 선행 이론 |
| study1 | 설치, `rails new`, 명령어, 첫 화면 | Rails 프로젝트 생성 |
| study2 | 모델과 마이그레이션 | 마이그레이션 |
| study3 | 스캐폴드가 만드는 MVC, 게시글 CRUD | 스캐폴드, REST 라우팅 |
| study4 | `has_many` / `belongs_to`, 댓글 | Active Record 관계 |
| study5 | 세션 로그인, 작성자만 수정 | 인증 (직접 구현, Devise와 비교) |
| study6 | 게시글 JSON API | 게시판 CRUD를 API로 |
| study7 | 중첩 댓글 API | REST 자원 |
| study8 | 작성자 권한, 페이지, 검색 | API를 목록 화면에서 쓸 준비 |
| study9 | 세션과 JWT | 인증을 API에 확장 |
| study10 | CORS, JS/TS 화면 | 별도 프론트 연동 |
| studyFinal | 미니 게시판 웹사이트 | 지금까지의 응용 |

인증은 Devise 젬으로 한 번에 붙일 수도 있습니다. 이 과정은 세션과 비밀번호 해시를 직접 만들어서, Devise가 숨기는 `session`, `has_secure_password`, `before_action`을 먼저 보게 합니다. 각 단계의 문서에서 Devise의 어느 기능에 해당하는지만 대응시킵니다.

## 8. 실습을 시작하기 전에 기억할 것

- 생성기가 만든 파일을 모르면 다음 단계가 막힙니다. study3에서 스캐폴드 결과를 읽고, 그 다음부터는 같은 모양을 손으로도 고칠 수 있어야 합니다.
- `db/schema.rb`는 결과물입니다. 테이블을 바꿀 때는 마이그레이션을 추가합니다.
- 학습용 비밀값은 개발 환경에만 둡니다. `config/master.key`와 로컬 SQLite 파일은 Git에 올리지 않습니다.
- 확인은 브라우저 주소와 테스트로 합니다. 문서의 "검증" 절은 그 실행 결과만 적습니다.

다음 문서는 [study1.md](study1.md)입니다. Ruby를 설치하고 `rails new`로 `demo/`를 만든 뒤 첫 화면을 띄웁니다.
