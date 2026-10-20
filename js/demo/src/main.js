import { commentUrl, commentsUrl, loginUrl, postUrl, postsUrl, requestJson } from "./api.js";

const origin = "http://127.0.0.1:3000";
const state = {
  token: readStore("rails.token"),
  nickname: readStore("rails.nickname"),
  page: 1,
  per: 5,
  q: "",
  postId: null
};

const status = document.querySelector("#status");
const posts = document.querySelector("#posts");
const meta = document.querySelector("#meta");
const detail = document.querySelector("#detail");
const detailTitle = document.querySelector("#detail-title");
const detailBody = document.querySelector("#detail-body");
const comments = document.querySelector("#comments");
const prev = document.querySelector("#prev");
const next = document.querySelector("#next");

function readStore(key) {
  try {
    return sessionStorage.getItem(key) || "";
  } catch {
    return "";
  }
}

function writeStore(key, value) {
  try {
    if (value) sessionStorage.setItem(key, value);
    else sessionStorage.removeItem(key);
  } catch {
    // 저장소를 못 쓰는 환경에서는 메모리 상태만 유지한다.
  }
}

function setStatus(text, isError = false) {
  status.textContent = text;
  status.classList.toggle("error", isError);
}

function showSession() {
  setStatus(state.token ? `${state.nickname} 로그인` : "로그인 전입니다. 목록은 볼 수 있습니다.");
}

async function loadPosts() {
  const data = await requestJson(postsUrl(origin, state), { token: state.token });
  posts.replaceChildren();
  for (const post of data.posts) {
    const article = document.createElement("article");
    const title = document.createElement("h2");
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = post.title;
    button.addEventListener("click", () => openPost(post.id));
    title.append(button);
    const line = document.createElement("p");
    line.textContent = post.author;
    article.append(title, line);
    posts.append(article);
  }
  const lastPage = Math.max(1, Math.ceil(data.meta.total / data.meta.per));
  meta.textContent = `${data.meta.total}건 · ${data.meta.page} / ${lastPage}`;
  prev.disabled = data.meta.page <= 1;
  next.disabled = data.meta.page * data.meta.per >= data.meta.total;
}

async function openPost(id) {
  const post = await requestJson(postUrl(origin, id), { token: state.token });
  state.postId = post.id;
  detail.hidden = false;
  detailTitle.textContent = post.title;
  detailBody.textContent = post.body;
  comments.replaceChildren();
  for (const comment of post.comments || []) {
    const item = document.createElement("li");
    item.textContent = `${comment.author}: ${comment.body}`;
    if (state.nickname && comment.author === state.nickname) {
      const button = document.createElement("button");
      button.type = "button";
      button.textContent = "삭제";
      button.addEventListener("click", () => removeComment(comment.id));
      item.append(" ", button);
    }
    comments.append(item);
  }
}

async function removeComment(id) {
  await requestJson(commentUrl(origin, state.postId, id), { method: "DELETE", token: state.token });
  await openPost(state.postId);
}

async function run(action) {
  try {
    await action();
  } catch (error) {
    setStatus(error.message, true);
  }
}

document.querySelector("#login").addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  run(async () => {
    const data = await requestJson(loginUrl(origin), {
      method: "POST",
      body: { email: form.email.value, password: form.password.value }
    });
    state.token = data.token;
    state.nickname = data.user.nickname;
    writeStore("rails.token", state.token);
    writeStore("rails.nickname", state.nickname);
    showSession();
    if (state.postId) await openPost(state.postId);
  });
});

document.querySelector("#logout").addEventListener("click", () => {
  state.token = "";
  state.nickname = "";
  writeStore("rails.token", "");
  writeStore("rails.nickname", "");
  showSession();
});

document.querySelector("#search").addEventListener("submit", (event) => {
  event.preventDefault();
  state.q = event.currentTarget.q.value.trim();
  state.page = 1;
  run(loadPosts);
});

prev.addEventListener("click", () => {
  state.page -= 1;
  run(loadPosts);
});

next.addEventListener("click", () => {
  state.page += 1;
  run(loadPosts);
});

document.querySelector("#new-post").addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  run(async () => {
    await requestJson(postsUrl(origin, {}), {
      method: "POST",
      token: state.token,
      body: { post: { title: form.title.value, body: form.body.value } }
    });
    form.reset();
    state.page = 1;
    showSession();
    await loadPosts();
  });
});

document.querySelector("#new-comment").addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  run(async () => {
    await requestJson(commentsUrl(origin, state.postId), {
      method: "POST",
      token: state.token,
      body: { comment: { body: form.body.value } }
    });
    form.reset();
    await openPost(state.postId);
  });
});

showSession();
run(loadPosts);
