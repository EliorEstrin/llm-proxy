# llm-proxy

A local, self-run proxy that sits between **Claude Code / Codex** and their providers, so that
logins, account selection and usage live in **one place I control through a UI** instead of
being scattered across every tool and machine.

**Status:** Phase 0 ready — proxy, UI and config are in place and boot-tested; no accounts logged in yet.
See [`docs/STATUS.md`](docs/STATUS.md) for the live checklist.

## Read this in order (humans and agents)

1. [`docs/goal.md`](docs/goal.md) — the end goal and why
2. [`docs/architecture.md`](docs/architecture.md) — how it works, what talks to what
3. [`docs/decisions.md`](docs/decisions.md) — what we chose and what we rejected
4. [`docs/STATUS.md`](docs/STATUS.md) — where we are right now
5. [`docs/test-plan.md`](docs/test-plan.md) — how we prove it works
6. [`docs/runbook.md`](docs/runbook.md) — login, run, service, cutover, rollback, upgrade
7. [`docs/open-questions.md`](docs/open-questions.md) — what is still unverified
8. [`docs/context.md`](docs/context.md) — where the idea came from, sources

## What is in here

| Path | What |
|---|---|
| `run.sh` | Starts the proxy (renders `config.yaml` from the template + `.secrets`) |
| `config.yaml.tmpl` | Our proxy config: localhost only, session affinity on, our UI |
| `bin/` | The pinned proxy binary (gitignored; version in `VERSION`) |
| `ui/management.html` | Our own build of the proxy's management UI (version in `ui/VERSION`) |
| `clients/` | `claude-proxy`, `codex-proxy` wrappers for the test phase |
| `scripts/check.sh` | Verification helper (up / accounts / models / direct) |
| `systemd/` | User service for the permanent setup (not installed until tests pass) |
| `dashboard/` | Our own dashboard, only if the stock UI falls short |
| `findings/` | Management-API dumps from the test phase (tokens stripped) |

## What is NOT in here

Real logins live in `~/.cli-proxy-api` (outside the repo). `.secrets` and the rendered `config.yaml`
are gitignored. The proxy itself is used **unmodified** — see `docs/decisions.md`.

## Notes
Personal setup notes, not a product. It runs a third-party, unofficial proxy ([CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI), MIT)
that holds real provider logins — read `docs/architecture.md` (security model) and check provider terms before copying this setup.
