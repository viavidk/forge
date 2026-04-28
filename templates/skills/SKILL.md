# Skills

Skills are automatically invoked based on context. Each skill has its own
README.md with full trigger conditions and steps.

| Skill            | Auto-trigger                                               | Loops? |
|------------------|------------------------------------------------------------|--------|
| security-review  | Auth, session, API service, or user-input code changes     | ≤ 3    |
| document         | After each completed module, before pre-commit             | No     |
| pre-commit       | User signals readiness to commit ("commit", "gem", "push") | ≤ 5    |
| deploy           | User requests production prep ("deploy", "klar til prod")  | Once   |
| ui-ux-pro-max    | Any UI/UX design request (if installed)                    | No     |
| frontend-design  | Any UI/UX design request (if installed, aesthetic quality) | No     |

## How skills relate to commands

- **Skills** are behavioural rules that auto-trigger on context
- **Commands** (`/project:*`) are explicit invocations the user types
- The BUILD → REVIEW → FIX loop lives in `/project:review` — not in a skill
  Skills may spawn that loop internally (pre-commit and deploy both do)

## Iteration limits are non-negotiable

Every skill and command that loops has a maximum iteration count. If the
limit is reached without passing the gate, STOP and escalate with a clear
message about what is persistently failing. Never loop forever.
