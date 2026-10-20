import { describe, expect, it } from "vitest";
import { healthUrl, welcomeMessage } from "./greeting";

describe("greeting", () => {
  it("matches the Rails home page", () => {
    expect(welcomeMessage()).toBe("Rails 실습에 오신 것을 환영합니다");
  });

  it("points at the Rails health path", () => {
    expect(healthUrl()).toBe("http://127.0.0.1:3000/up");
  });
});
