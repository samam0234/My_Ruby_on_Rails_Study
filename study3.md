# study3. 실습3 — 스캐폴드와 템플릿 CRUD

study2의 `Post`를 화면으로 꺼냅니다. Notion의 "스캐폴드로 모델 / 컨트롤러 / 뷰 생성"과 "REST 라우팅"이 이 문서의 목표입니다.

모델은 이미 있으므로 스캐폴드를 통째로 다시 돌리지는 않았습니다. 스캐폴드가 만드는 컨트롤러, 뷰, `resources` 라우트를 같은 모양으로 작성하고, 생성기 명령은 아래에서 대응시켜 읽습니다.

## 1. 스캐폴드가 하는 일

빈 프로젝트에서 아래 명령 한 줄이면 마이그레이션, 모델, 컨트롤러, 뷰, 라우트, 테스트 초안이 생깁니다.

```powershell
bundle exec rails generate scaffold Post title:string body:text
```

Django로 치면 모델과 제네릭 뷰(List, Detail, Create, Update, Delete)와 URL을 한 번에 만드는 일에 가깝습니다. Django Admin처럼 관리 화면이 같이 생기지는 않습니다. Rails는 우리가 보는 템플릿이 곧 화면입니다.

이미 `posts` 테이블이 있으면 이 명령을 그대로 실행하면 마이그레이션이 겹칩니다. 그래서 이 실습은 생성기 결과에 해당하는 파일을 직접 두고, 다음부터는 그 파일을 고칠 수 있게 했습니다.

## 2. resources 라우트

```ruby
resources :posts
```

이 한 줄이 일곱 경로를 만듭니다.

| HTTP | 경로 | 액션 | 하는 일 |
|---|---|---|---|
| GET | /posts | index | 목록 |
| GET | /posts/new | new | 작성 폼 |
| POST | /posts | create | 저장 |
| GET | /posts/:id | show | 한 건 |
| GET | /posts/:id/edit | edit | 수정 폼 |
| PATCH | /posts/:id | update | 수정 반영 |
| DELETE | /posts/:id | destroy | 삭제 |

`GET /posts/new`가 `GET /posts/:id`보다 위에 정의되어야 "new"가 id로 오해되지 않습니다. `resources`가 그 순서를 지켜 줍니다.

## 3. 컨트롤러와 Strong Parameters

```ruby
def create
  @post = Post.new(post_params)
  if @post.save
    redirect_to @post, notice: "글을 저장했습니다."
  else
    render :new, status: :unprocessable_entity
  end
end

def post_params
  params.require(:post).permit(:title, :body)
end
```

`permit`에 없는 키는 모델에 전달되지 않습니다. 나중에 `user_id`를 숨기는 이유도 여기 있습니다. 클라이언트가 작성자를 골라 넣지 못하게 하려면 permit 목록에 넣지 않습니다.

검증에 실패하면 422로 폼을 다시 그립니다. 성공하면 상세 주소로 리다이렉트합니다. 새로고침이 저장을 한 번 더 하지 않게 하려는 패턴입니다.

`form_with`는 CSRF 토큰을 넣습니다. 토큰 없는 POST는 Rails가 거절합니다.

## 4. 템플릿

| 파일 | 역할 |
|---|---|
| `app/views/posts/index.html.erb` | 목록. 글이 없으면 "아직 글이 없습니다." |
| `app/views/posts/show.html.erb` | 제목, 본문, 수정, 삭제 |
| `app/views/posts/new.html.erb` | 작성 |
| `app/views/posts/edit.html.erb` | 수정 |
| `app/views/posts/_form.html.erb` | 작성/수정이 공유하는 폼 |

삭제 버튼은 `button_to ..., method: :delete`입니다. 실제 HTML은 POST 폼이고, 숨은 `_method` 값이 `delete`입니다. 브라우저가 DELETE를 직접 보내지 않아도 Rails가 액션을 구분합니다.

레이아웃 내비게이션에 "게시글" 링크를 추가했습니다.

## 5. 댓글이 달린 글은 아직 지워지지 않는다

`comments.post_id`는 `posts`를 외래 키로 참조합니다. 댓글이 남아 있는데 글을 지우면 SQLite가 `ActiveRecord::InvalidForeignKey`로 막습니다. 통합 테스트가 그 경우를 그대로 확인합니다.

글을 지울 때 댓글도 지우는 선언은 study4의 `dependent: :destroy`입니다. 지금 막힌 것이 버그가 아니라, 관계를 아직 덜 적었다는 신호입니다.

## 6. 검증 결과

`bundle exec rails test`:

```text
15 runs, 38 assertions, 0 failures, 0 errors, 0 skips
```

개발 서버 `GET http://127.0.0.1:3000/posts`는 200이었습니다. 개발 DB에는 테스트 픽스처가 들어가지 않아서 화면 문구는 "아직 글이 없습니다."였고, "글쓰기" 링크는 `/posts/new`를 가리켰습니다. 저장, 수정, 삭제, 빈 제목 422, 없는 id의 404, 댓글이 있는 글의 삭제 거부는 통합 테스트가 확인했습니다.

다음 문서는 [study4.md](study4.md)입니다. 회원과 글, 글과 댓글을 양쪽으로 연결합니다.
