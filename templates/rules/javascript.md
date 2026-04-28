# JavaScript conventions

- Vanilla JS preferred — no frameworks unless explicitly required
- Use `fetch()` for all REST API calls — never XMLHttpRequest
- Always handle fetch errors explicitly:
  ```js
  const res = await fetch(url, options);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  ```
- Async/await over raw `.then()` chains — easier to read and debug
- Never store API keys, tokens, or secrets in client-side JS
- CSRF token must be included in all state-changing requests (POST/PUT/DELETE):
  ```js
  headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content }
  ```
- Escape all dynamic content inserted into the DOM — never use `innerHTML` with user data, use `textContent` or `createElement`
- Event listeners attached via `addEventListener`, never inline `onclick` attributes
- Group fetch calls in a dedicated `api.js` module — no fetch calls scattered in view files
