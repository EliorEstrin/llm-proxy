# Status

**Phase:** 0 — ground prepared. Waiting for the owner to log in accounts (browser OAuth).

| Item | State | Evidence |
|---|---|---|
| Repo + docs | done | this repo |
| Proxy binary v8.0.13 (no-plugin), checksum | done | `sha256sum -c` OK, 2026-10-03 |
| Proxy boots, localhost only, 401 without key / 200 with key | verified live | 2026-10-03 |
| Management API answers (empty account list) | verified live | 2026-10-03 |
| Our UI build v1.25.3 served at /management.html | verified live (HTTP 200, no panel download) | 2026-10-03 |
| Client wrappers `claude-proxy`, `codex-proxy` | written, **untested** (need a login) | `clients/` |
| `scripts/check.sh` | `up` and `accounts` verified live (0 accounts); `models`/`direct` need a login | `scripts/` |
| systemd unit | written, **not installed** | `systemd/` |
| Accounts logged in | **no** — owner step | `docs/runbook.md` |
| Checks 3–7 of the test plan | not run | `docs/test-plan.md` |
| Cutover of plain `claude`/`codex` | not started | `docs/runbook.md` |
