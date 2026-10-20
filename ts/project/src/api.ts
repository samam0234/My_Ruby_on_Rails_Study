export type Post = {
  id: number;
  title: string;
  body: string;
  author: string;
  created_at: string;
  comments?: Comment[];
};

export type Comment = {
  id: number;
  body: string;
  author: string;
  created_at: string;
};

export type PageMeta = { page: number; per: number; total: number };

export type PostPage = { posts: Post[]; meta: PageMeta };

export type Session = {
  token: string;
  user: { id: number; email: string; nickname: string };
};

type Query = { q?: string; page?: number; per?: number };

export function postsUrl(origin: string, { q = "", page = 1, per = 10 }: Query = {}): string {
  const url = new URL("/api/v1/posts", origin);
  if (q) url.searchParams.set("q", q);
  url.searchParams.set("page", String(page));
  url.searchParams.set("per", String(per));
  return url.toString();
}

export function loginUrl(origin: string): string {
  return new URL("/api/v1/login", origin).toString();
}

export function postUrl(origin: string, id: number): string {
  return new URL(`/api/v1/posts/${id}`, origin).toString();
}

export function commentsUrl(origin: string, postId: number): string {
  return new URL(`/api/v1/posts/${postId}/comments`, origin).toString();
}

export function commentUrl(origin: string, postId: number, commentId: number): string {
  return new URL(`/api/v1/posts/${postId}/comments/${commentId}`, origin).toString();
}

export function errorMessage(data: unknown, status: number): string {
  if (data && typeof data === "object" && "error" in data && typeof data.error === "string") {
    return data.error;
  }
  if (data && typeof data === "object" && "errors" in data && data.errors && typeof data.errors === "object") {
    const first = Object.values(data.errors as Record<string, string[]>).flat()[0];
    if (first) return String(first);
  }
  return `HTTP ${status}`;
}

export async function requestJson<T>(url: string, options: { method?: string; token?: string; body?: unknown } = {}): Promise<T> {
  const headers: Record<string, string> = { accept: "application/json" };
  if (options.body !== undefined) headers["content-type"] = "application/json";
  if (options.token) headers.authorization = `Bearer ${options.token}`;

  const response = await fetch(url, {
    method: options.method ?? "GET",
    headers,
    body: options.body === undefined ? undefined : JSON.stringify(options.body)
  });
  const text = await response.text();
  const data: unknown = text ? JSON.parse(text) : null;
  if (!response.ok) {
    throw new Error(errorMessage(data, response.status));
  }
  return data as T;
}
