# study1. 만드는 방법 및 명령어, 실습1

study0의 지도를 실제 폴더로 만듭니다. Rails 앱은 `demo/`에 두고, 화면용 JavaScript와 TypeScript는 각자 `js/demo`, `ts/demo`에서 따로 실행합니다.

이번 실습의 끝 상태는 주소 `/`에 환영 화면이 나오고, `/up`이 200을 주는 것입니다.

## 1. 개발 환경

이 저장소를 확인한 환경은 아래와 같습니다.

| 도구 | 버전 |
|---|---|
| Ruby | 3.4.11 (RubyInstaller, `C:\Ruby34-x64`) |
| Rails | 8.1.4 |
| Node.js | 24.14.0 |

Windows에는 Ruby가 기본으로 없습니다. [RubyInstaller](https://rubyinstaller.org/)의 Ruby 3.4 with DevKit을 설치한 뒤 새 터미널에서 확인합니다.

```powershell
ruby -v
gem install rails -v 8.1.4 --no-document
rails -v
```

설치 직후의 터미널은 `ruby`를 못 찾을 수 있습니다. 그때는 `C:\Ruby34-x64\bin`을 PATH에 넣거나 터미널을 다시 엽니다.

### Windows에서 bundle이 rbs 컴파일에 실패할 때

이 환경 변수 `DEBUG`에 `WARN`이 들어 있었습니다. `rbs` 확장은 `DEBUG`가 있으면 컴파일 옵션에 `-pg`를 넣고, 그 상태에서 Windows 링커가 `__fentry__`를 못 찾아 `bundle install`이 멈췄습니다. Rails와 상관없는 값이면 끄고 다시 설치합니다.

```powershell
Remove-Item Env:DEBUG
bundle install
```

## 2. 프로젝트 생성 명령어

저장소 루트에서 `demo`라는 폴더로 앱을 만들었습니다. 모듈 이름은 `RailsStudy`입니다. 배포용 Kamal, Solid Queue, Thruster, Docker, CI, RuboCop은 학습 범위 밖이라 건너뛰었습니다. JavaScript 번들도 빼서, 브라우저 쪽 실습은 `js/`, `ts/` 폴더가 맡게 했습니다.

```powershell
rails new demo --database=sqlite3 --name=RailsStudy `
  --skip-kamal --skip-solid --skip-thruster `
  --skip-action-mailbox --skip-action-text --skip-action-cable `
  --skip-docker --skip-ci --skip-brakeman --skip-rubocop --skip-bundler-audit `
  --skip-system-test --skip-javascript
```

`rails new`는 `demo/.git`을 새로 만듭니다. 이 저장소는 루트가 이미 Git 저장소이므로 중첩된 `demo/.git`은 지웠습니다. `config/master.key`는 자격 증명 암호키라 `.gitignore`에 의해 커밋되지 않습니다.

생성 직후 자주 여는 파일은 세 개입니다.

- `Gemfile`: Rails 8.1.4, Puma, SQLite, Propshaft, Jbuilder
- `config/routes.rb`: URL과 컨트롤러를 연결
- `config/database.yml`: 개발 DB는 `storage/development.sqlite3`

SQLite 파일, `log/`, `tmp/`는 Git에 올리지 않습니다.

## 3. 자주 쓰는 명령어

모두 `demo/` 안에서 실행합니다.

```powershell
bundle exec rails server          # http://127.0.0.1:3000
bundle exec rails routes          # 경로 목록
bundle exec rails test            # Minitest
bundle exec rails db:prepare      # DB 생성과 마이그레이션
bundle exec rails console         # 모델 실험용 REPL
bundle exec rails generate MODEL  # 다음 실습에서 사용
```

서버를 끈 뒤 DB를 처음부터 다시 만들고 싶으면 `bundle exec rails db:reset`을 씁니다. 개발용 데이터가 사라집니다.

## 4. 설정에서 먼저 바꾼 것

`config/application.rb`에 시간대와 언어를 적었습니다. 번역이 없는 키는 영어로 떨어지게 해 두었습니다.

```ruby
config.time_zone = "Seoul"
config.i18n.available_locales = [ :ko, :en ]
config.i18n.default_locale = :ko
config.i18n.fallbacks = [ :en ]
```

Django의 `TIME_ZONE`, `LANGUAGE_CODE`와 같은 자리입니다.

## 5. 실습1: 첫 화면

라우트 한 줄이 컨트롤러 액션을 고릅니다.

```ruby
root "home#index"
get "up" => "rails/health#show", as: :rails_health_check
```

`home#index`는 `HomeController`의 `index` 메서드입니다. 액션이 비어 있으면 Rails는 같은 이름의 템플릿을 찾습니다.

```ruby
class HomeController < ApplicationController
  def index
  end
end
```

템플릿은 `app/views/home/index.html.erb`입니다. 레이아웃 `app/views/layouts/application.html.erb`가 그 안을 `yield`로 감쌉니다. Django의 `base.html`과 `{% block %}` 관계와 같습니다.

확인한 경로는 둘입니다.

| 경로 | 컨트롤러 | 응답 |
|---|---|---|
| `GET /` | `home#index` | 200, 제목 "Rails 실습에 오신 것을 환영합니다" |
| `GET /up` | `rails/health#show` | 200 |

## 6. JavaScript 폴더와 TypeScript 폴더

Rails 서버와 별개로 두 화면을 만들었습니다. 문구와 Rails 상태 주소는 같고, 언어와 실행 방법만 다릅니다.

```powershell
cd js\demo
node --test
node server.mjs          # http://127.0.0.1:5173
```

```powershell
cd ts\demo
npm install
npm test
npm run dev              # http://127.0.0.1:5174
```

`js/demo/src/greeting.js`와 `ts/demo/src/greeting.ts`가 환영 문구를 만듭니다. HTML은 그 함수 결과를 제목에 넣습니다. 아직 Rails API를 호출하지는 않습니다. JSON API는 study6 이후에 붙입니다.

## 7. 검증 결과

`demo/`에서 `bundle exec rails test`:

```text
2 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

개발 서버 `http://127.0.0.1:3000/`는 200이었습니다. 본문에 환영 제목이 있고, 스타일시트는 `/assets/application-3b7dbaf9.css`로 연결되었습니다. `GET /up`도 200이었습니다.

`js/demo`의 `node --test`는 2개 통과, 정적 서버 `http://127.0.0.1:5173/`도 200이었습니다. `ts/demo`의 `npm test`는 2개 통과, `npm run build`도 성공했습니다.

브라우저 자동화 도구는 이 환경에 없어서, 화면 클릭 대신 통합 테스트와 HTTP 응답으로 확인했습니다.

## 8. 이 단계에서 일부러 안 한 것

- 게시글 모델과 마이그레이션은 study2입니다.
- 스캐폴드와 폼은 study3입니다.
- 로그인은 study5입니다. 지금은 누구나 첫 화면만 봅니다.

다음 문서는 [study2.md](study2.md)입니다.
