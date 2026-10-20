import { commentUrl, commentsUrl, loginUrl, postUrl, postsUrl, requestJson, type Comment, type Post, type PostPage, type Session } from "./api";

const origin = "http://127.0.0.1:3000";
const state = {
  token: readStore("rails.token"),
  nickname: readStore("rails.nickname"),
  page: 1,
  per: 5,
  q: "",
  postId: null as number | null
};

const status = document.querySelector<HTMLElement>("#status");
const posts = document.querySelector<HTMLElement>("#posts");
const meta = document.querySelector<HTMLElement>("#meta");
const detail = document.querySelector<HTMLElement>("#detail");
const detailTitle = document.querySelector<HTMLElement>("#detail-title");
const detailBody = document.querySelector<HTMLElement>("#detail-body");
const comments = document.querySelector<HTMLElement>("#comments");
const prev = document.querySelector<HTMLButtonElement>("#prev");
const next = document.querySelector<HTMLButtonElement>("#next");

function readStore(key: string): string {
  try {
    return sessionStorage.getItem(key) || "";
  } catch {
    return "";
  }
}

function writeStore(key: string, value: string): void {
  try {
    if (value) sessionStorage.setItem(key, value);
    else sessionStorage.removeItem(key);
  } catch {
    // 저장소를 못 쓰는 환경에서는 메모리 상태만 유지한다.
  }
}

function setStatus(text: string, isError = false): void {
  if (!status) return;
  status.textContent = text;
  status.classList.toggle("error", isError);
}

function showSession(): void {
  setStatus(state.token ? `${state.nickname} 로그인` : "로그인 전입니다. 목록은 볼 수 있습니다.");
}

async function loadPosts(): Promise<void> {
  if (!posts || !meta || !prev || !next) return;
  const data = await requestJson<PostPage>(postsUrl(origin, state), { token: state.token });
  posts.replaceChildren();
  for (const post of data.posts) {
    const article = document.createElement("article");
    const title = document.createElement("h2");
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = post.title;
    button.addEventListener("click", () => {
      void run(() => openPost(post.id));
    });
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

async function openPost(id: number): Promise<void> {
  if (!detail || !detailTitle || !detailBody || !comments) return;
  const post = await requestJson<Post>(postUrl(origin, id), { token: state.token });
  state.postId = post.id;
  detail.hidden = false;
  detailTitle.textContent = post.title;
  detailBody.textContent = post.body;
  comments.replaceChildren();
  for (const comment of post.comments ?? []) {
    comments.append(commentItem(comment));
  }
}

function commentItem(comment: Comment): HTMLLIElement {
  const item = document.createElement("li");
  item.textContent = `${comment.author}: ${comment.body}`;
  if (state.nickname && comment.author === state.nickname && state.postId) {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = "삭제";
    const postId = state.postId;
    button.addEventListener("click", () => {
      void run(async () => {
        await requestJson(commentUrl(origin, postId, comment.id), { method: "DELETE", token: state.token });
        await openPost(postId);
      });
    });
    item.append(" ", button);
  }
  return item;
}

async function run(action: () => Promise<void>): Promise<void> {
  try {
    await action();
  } catch (error) {
    setStatus(error instanceof Error ? error.message : "요청에 실패했습니다.", true);
  }
}

document.querySelector<HTMLFormElement>("#login")?.addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.currentTarget as HTMLFormElement;
  const email = (form.elements.namedItem("email") as HTMLInputElement).value;
  const password = (form.elements.namedItem("password") as HTMLInputElement).value;
  void run(async () => {
    const data = await requestJson<Session>(loginUrl(origin), { method: "POST", body: { email, password } });
    state.token = data.token;
    state.nickname = data.user.nickname;
    writeStore("rails.token", state.token);
    writeStore("rails.nickname", state.nickname);
    showSession();
    if (state.postId) await openPost(state.postId);
  });
});

document.querySelector("#logout")?.addEventListener("click", () => {
  state.token = "";
  state.nickname = "";
  writeStore("rails.token", "");
  writeStore("rails.nickname", "");
  showSession();
});

document.querySelector<HTMLFormElement>("#search")?.addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.currentTarget as HTMLFormElement;
  state.q = (form.elements.namedItem("q") as HTMLInputElement).value.trim();
  state.page = 1;
  void run(loadPosts);
});

prev?.addEventListener("click", () => {
  state.page -= 1;
  void run(loadPosts);
});

next?.addEventListener("click", () => {
  state.page += 1;
  void run(loadPosts);
});

document.querySelector<HTMLFormElement>("#new-post")?.addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.currentTarget as HTMLFormElement;
  const title = (form.elements.namedItem("title") as HTMLInputElement).value;
  const body = (form.elements.namedItem("body") as HTMLTextAreaElement).value;
  void run(async () => {
    await requestJson(postsUrl(origin), { method: "POST", token: state.token, body: { post: { title, body } } });
    form.reset();
    state.page = 1;
    showSession();
    await loadPosts();
  });
});

document.querySelector<HTMLFormElement>("#new-comment")?.addEventListener("submit", (event) => {
  event.preventDefault();
  const form = event.currentTarget as HTMLFormElement;
  const body = (form.elements.namedItem("body") as HTMLInputElement).value;
  void run(async () => {
    if (!state.postId) return;
    await requestJson(commentsUrl(origin, state.postId), {
      method: "POST",
      token: state.token,
      body: { comment: { body } }
    });
    form.reset();
    await openPost(state.postId);
  });
});

showSession();
void run(loadPosts);
