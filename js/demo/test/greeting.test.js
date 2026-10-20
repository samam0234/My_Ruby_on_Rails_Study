import assert from "node:assert/strict";
import test from "node:test";
import { healthUrl, welcomeMessage } from "../src/greeting.js";

test("welcome message matches the Rails home page", () => {
  assert.equal(welcomeMessage(), "Rails 실습에 오신 것을 환영합니다");
});

test("health url points at the Rails /up path", () => {
  assert.equal(healthUrl(), "http://127.0.0.1:3000/up");
});
