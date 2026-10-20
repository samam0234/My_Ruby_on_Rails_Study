import { healthUrl, welcomeMessage } from "./greeting";

const title = document.querySelector("#title");
const link = document.querySelector<HTMLAnchorElement>("#health");

if (title) title.textContent = welcomeMessage();
if (link) {
  link.href = healthUrl();
  link.textContent = healthUrl();
}
