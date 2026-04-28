# Testing and validation

- Validate every feature end-to-end before marking done
- Test happy path AND failure paths (wrong password, empty input, expired session)
- After every fix: verify the specific issue is resolved and no regressions introduced
- Authentication tests must cover: login, logout, session expiry, role enforcement
- API integration tests must use real credentials for final validation. Use recorded responses (fixtures) during development loops.
- SQL: verify prepared statements by attempting injection in inputs
