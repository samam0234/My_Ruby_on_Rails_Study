# js/project 5180, ts/project 5181. demo 클라이언트 포트도 같이 연다.
# 쿠키 대신 Authorization 헤더를 쓰므로 credentials는 열지 않는다.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      "http://127.0.0.1:5173",
      "http://localhost:5173",
      "http://127.0.0.1:5174",
      "http://localhost:5174",
      "http://127.0.0.1:5180",
      "http://localhost:5180",
      "http://127.0.0.1:5181",
      "http://localhost:5181"
    )

    resource "/api/*",
      headers: :any,
      methods: %i[get post patch put delete options head]
  end
end
