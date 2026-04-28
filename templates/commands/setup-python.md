# /project:setup-python

Set up a Python virtual environment for this project.

## Steps

1. Create venv: python3 -m venv .venv
2. Activate: source .venv/bin/activate
3. Install dependencies: pip install -r requirements.txt
4. Verify .venv/ is already in .gitignore — it is added by default by Forge
5. Confirm: python --version + pip list
