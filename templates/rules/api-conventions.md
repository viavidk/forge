# API conventions

- All external API calls live in `/app/services/`
- Every service method must:
  - Retry on transient failure (max 3 attempts, exponential backoff)
  - Log request + response to `api_logs` table
  - Throw typed exceptions on failure — never return false/null silently
- API credentials loaded from `$_ENV` only
- Never expose raw API errors or stack traces to the user
- Services are stateless — no session or global state inside a service
