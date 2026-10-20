import { afterEach, describe, expect, it, vi } from "vitest";
import { errorMessage, loginUrl, postsUrl, requestJson } from "./api";

describe("api", () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("keeps search, page, and per", () => {
    const url = new URL(postsUrl("http://127.0.0.1:3000", { q: "메모", page: 2, per: 1 }));
    expect(url.pathname).toBe("/api/v1/posts");
    expect(url.searchParams.get("q")).toBe("메모");
    expect(url.searchParams.get("page")).toBe("2");
    expect(url.searchParams.get("per")).toBe("1");
  });

  it("points login at the token endpoint", () => {
    expect(loginUrl("http://127.0.0.1:3000")).toBe("http://127.0.0.1:3000/api/v1/login");
  });

  it("reads the api error string", () => {
    expect(errorMessage({ error: "로그인이 필요합니다." }, 401)).toBe("로그인이 필요합니다.");
    expect(errorMessage({ errors: { title: ["제목을 입력하세요"] } }, 422)).toBe("제목을 입력하세요");
  });

  it("sends a bearer token", async () => {
    const fetchMock = vi.fn(async (_url: string, _options?: RequestInit) => {
      return new Response(JSON.stringify({ token: "abc" }), { status: 200 });
    });
    vi.stubGlobal("fetch", fetchMock);
    await requestJson("http://127.0.0.1:3000/api/v1/login", { method: "POST", token: "abc", body: { email: "a@b.c" } });
    const options = fetchMock.mock.calls[0][1];
    expect((options?.headers as Record<string, string>).authorization).toBe("Bearer abc");
  });
});
