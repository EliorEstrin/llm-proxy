# Status

**Phase:** 1 — accounts logged in, test plan run, proxy running as a user service (2026-10-03). Plain `claude`/`codex` not cut over yet; use `claude-proxy`/`codex-proxy`.

| Item | State | Evidence |
|---|---|---|
| Repo + docs | done | this repo |
| Proxy binary v8.0.13 (no-plugin), checksum | done | `sha256sum -c` OK, 2026-10-03 |
| Proxy boots, localhost only, 401 without key / 200 with key | verified live | 2026-10-03 |
| Our UI build v1.25.3 served at /management.html | verified live (HTTP 200, no panel download) | 2026-10-03 |
| Accounts logged in | **3** — Claude x2, Codex x1 (owner did the browser logins) | `scripts/check.sh accounts` |
| Client wrappers `claude-proxy`, `codex-proxy` | verified live: both answer, scratch homes, real logins untouched | tests 4–5 |
| Test 3 direct request | passed (Claude `claude-opus-4-8`, Codex `gpt-5.5` via chat completions) | 2026-10-03 |
| Test 4 Claude Code through proxy | passed, serving account's count +1 | 2026-10-03 |
| Test 5 Codex through proxy | passed, `provider: llmproxy`, count +1 | 2026-10-03 |
| Test 6 account control | passed: disabling one Claude account via `PATCH /v0/management/auth-files/status` moved the next request to the other (count +1 there, none on the disabled one) | 2026-10-03 |
| Test 7 failure is visible | **partial**: no silent fallback to the old login, but with the proxy down `claude-proxy -p` produced no output and hung until a 60 s timeout (exit 124) — not a clear error | 2026-10-03 |
| Test 8 data for a dashboard | passed: after one request `quota` is populated for Claude (Anthropic unified 5h/7d status, utilization, reset) and Codex (plan, credits, limits), per account and per model | 2026-10-03 |
| systemd unit | **installed and enabled** on this workstation; comes up with all 3 accounts | `systemctl --user status llm-proxy`, 2026-10-03 |
| Cutover of plain `claude`/`codex` | not started | `docs/runbook.md` |

## Findings worth knowing
- **Counters are in memory.** Per-account success/failed counts reset to 0 when the proxy restarts. `quota` fills in only after a request has gone through that account.
- **`scripts/check.sh direct codex` used to pick an image model** (`gpt-image-2.5-flare`), which the chat endpoint rejects. Fixed: it now skips image/review models.
- **Round-robin did not alternate in testing.** Consecutive Claude requests went to the same account until it was disabled. Session affinity may explain it; not investigated.
- **Login timeout.** `-claude-login` gives up after about 5 minutes without the browser callback; just rerun it.
- **Open questions:** 3 (Claude quota) is answered — reported after a request. 7 (scratch home onboarding) is answered — `claude-proxy -p` ran with no prompt. See `docs/open-questions.md`.
