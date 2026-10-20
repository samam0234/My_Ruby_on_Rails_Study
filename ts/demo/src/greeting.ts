export function welcomeMessage(): string {
  return "Rails 실습에 오신 것을 환영합니다";
}

export function healthUrl(origin = "http://127.0.0.1:3000"): string {
  return `${origin}/up`;
}
