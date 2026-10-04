# Status

**Phase:** 1 — accounts logged in, test plan run, proxy running as a user service (2026-10-03). Cutover done 2026-10-05: plain `claude`/`codex` go through the proxy.

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
| systemd unit | **installed and enabled** on this workstation (reinstalled 2026-10-04; accounts re-logged in, 3 total) | `systemctl --user status llm-proxy`, 2026-10-03 |
| 404 lockout watchdog `llm-proxy-unstick` | **installed, verified live**: a 404 locked a model on both accounts (then 503); the service cleared both within 10 s; Sonnet/Opus 200 after | `journalctl --user -u llm-proxy-unstick`, 2026-10-05 |
| Cutover of plain `claude`/`codex` | **done, verified live**: plain `claude -p` and `codex exec` answered and the per-account counts rose. Backups: `~/.claude/settings.json.bak-20261004-235947`, `~/.codex/config.toml.bak-20261004-235947`. Codex reads `LLM_PROXY_KEY`, exported from `~/.zshenv` | 2026-10-05 |

## Findings worth knowing
- **Any upstream 404 locks a model for 12 h, and Anthropic's `thread_not_found` is a 404.** On 2026-10-05 Claude Code continued a conversation
  whose server-side thread was not on the chosen account; Anthropic answered 404, the proxy tried the other account (same 404), and
  `claude-sonnet-5-5` was dead on both accounts: every Sonnet request (including subagents) got an instant 503 while Opus worked.
  Upstream exempts only the OpenAI equivalent (`internal/clienterror/client_error.go` `IsItemNotPersisted`; 12 h in
  `sdk/cliproxy/auth/conductor_cooldown.go`, v8.0.13 = latest). A locked model also disappears from `/v1/models`. Fixed for us by
  `scripts/unstick.sh` (service `llm-proxy-unstick`), which resets 404 cooldowns via `POST /v8/management/routing/cooldown/reset`.
  Upstream: issue router-for-me/CLIProxyAPI#6344, fix PRs #6345 and #6265 (open, unreleased as of 2026-10-05). On an upgrade that
  includes them, retire the watchdog: `systemctl --user disable --now llm-proxy-unstick`, delete the script, unit and these notes.
- **Counters are in memory.** Per-account success/failed counts reset to 0 when the proxy restarts. `quota` fills in only after a request has gone through that account.
- **`scripts/check.sh direct codex` used to pick an image model** (`gpt-image-2.5-flare`), which the chat endpoint rejects. Fixed: it now skips image/review models.
- **Round-robin did not alternate in testing.** Consecutive Claude requests went to the same account until it was disabled. Session affinity may explain it; not investigated.
- **Login timeout.** `-claude-login` gives up after about 5 minutes without the browser callback; just rerun it.
- **Open questions:** 3 (Claude quota) is answered — reported after a request. 7 (scratch home onboarding) is answered — `claude-proxy -p` ran with no prompt. See `docs/open-questions.md`.
