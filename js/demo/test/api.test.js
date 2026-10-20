import assert from "node:assert/strict";
import test from "node:test";
import { errorMessage, loginUrl, postsUrl, requestJson } from "../src/api.js";

test("posts url keeps search, page, and per", () => {
  const url = new URL(postsUrl("http://127.0.0.1:3000", { q: "메모", page: 2, per: 1 }));
  assert.equal(url.pathname, "/api/v1/posts");
  assert.equal(url.searchParams.get("q"), "메모");
  assert.equal(url.searchParams.get("page"), "2");
  assert.equal(url.searchParams.get("per"), "1");
});

test("login url points at the token endpoint", () => {
  assert.equal(loginUrl("http://127.0.0.1:3000"), "http://127.0.0.1:3000/api/v1/login");
});

test("error message prefers the api error string", () => {
  assert.equal(errorMessage({ error: "로그인이 필요합니다." }, 401), "로그인이 필요합니다.");
  assert.equal(errorMessage({ errors: { title: ["제목을 입력하세요"] } }, 422), "제목을 입력하세요");
});

test("requestJson sends a bearer token", async () => {
  const original = globalThis.fetch;
  let seen = "";
  globalThis.fetch = async (_url, options) => {
    seen = options.headers.authorization;
    return new Response(JSON.stringify({ posts: [], meta: { page: 1, per: 5, total: 0 } }), { status: 200 });
  };
  try {
    const data = await requestJson("http://127.0.0.1:3000/api/v1/posts", { token: "abc" });
    assert.equal(seen, "Bearer abc");
    assert.equal(data.meta.total, 0);
  } finally {
    globalThis.fetch = original;
  }
});
