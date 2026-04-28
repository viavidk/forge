# Python conventions

- Python 3.10+ with type hints on all function signatures
- Use `pathlib.Path` over `os.path` for file operations
- Use `httpx` or `requests` for HTTP — never `urllib` directly
- All secrets via environment variables (`os.environ`) — never hardcoded
- Scripts that run as cron jobs must log to stdout with timestamps:
  ```python
  import logging
  logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')
  ```
- REST API calls must handle timeouts, retries (use `tenacity`), and non-2xx responses
- Use `argparse` for any script that takes command-line arguments
- Virtual environment (`venv`) — never install globally
- Requirements in `requirements.txt`, pinned versions
