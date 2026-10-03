# llm-proxy — agent briefing

You are working on a personal tool of Elior Estrin. Read `README.md`, then `docs/` in the order it lists.
Elior types fast with typos — parse intent. Be direct, structured, no fluff.

## What this is
A local self-run [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) in front of Claude Code and Codex, with the
project's own management UI, so Elior can operate which subscription account is active and see usage/connection.
End goal: `docs/goal.md`. How it fits together: `docs/architecture.md`.

## Rules
- **Never print or commit secrets.** `.secrets`, `config.yaml`, and everything in `~/.cli-proxy-api` hold real tokens.
  Read keys inside scripts; do not echo them, paste them, or put them in findings.
- **Use the proxy unmodified.** No forking or patching without a new entry in `docs/decisions.md`. Configure it, don't change it.
- **Don't touch Elior's real setup without asking:** `~/.claude/settings.json`, `~/.codex/config.toml` and their logins.
  Tests use the scratch homes the wrappers create. The permanent cutover is a deliberate, approved step (`docs/runbook.md`).
- **Logins are Elior's.** OAuth in the browser is his step; never try to automate or work around it.
- **Never guess.** Mark claims *verified live* vs *inferred*; record unknowns in `docs/open-questions.md`.
- **Align before building.** New designs: discuss first. No pushes, no new repos on GitHub until he says go.
- **Git:** commit as Elior — no co-author, no AI trailers, prose messages. Don't assume backward compatibility.
- Keep `docs/STATUS.md` truthful after any meaningful change.

## Quick commands
`./run.sh` start · `./run.sh -claude-login` / `-codex-device-login` log an account in · `scripts/check.sh up|accounts|models|direct`
UI: http://127.0.0.1:8317/management.html (management key = `MGMT_SECRET` in `.secrets`).
