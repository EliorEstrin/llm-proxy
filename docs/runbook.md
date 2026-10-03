# Runbook

## Start / stop
`./run.sh` (foreground). First run generates `.secrets`. Stop with Ctrl-C (or `kill` its PID — don't `pkill -f` from a shell that also matches its own command line).

## Log an account in (owner step, browser)
```
./run.sh -claude-login           # repeat per Claude account; sign in to the right account in the browser each time
./run.sh -codex-device-login     # device-code flow, works in WSL
```
Each login creates one credential file in `~/.cli-proxy-api/`. Verify: `scripts/check.sh accounts` or the UI.

## UI
http://127.0.0.1:8317/management.html — management key is `MGMT_SECRET` in `.secrets`.

## Test the clients (phase 1)
`clients/claude-proxy` and `clients/codex-proxy` (linked into `~/.local/bin`) use scratch homes by default, so the real login is untouched.
`LLM_PROXY_REAL_HOME=1` uses the real config dir instead (still proxy-routed). Then follow `docs/test-plan.md`.

## Make it permanent (phase 2 — only after checks 3–7 pass; ask the owner first)
1. Back up `~/.claude/settings.json` and `~/.codex/config.toml`.
2. `scripts/install-service.sh` — user systemd unit, auto-start (linger is on for this user).
3. Claude Code: add `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` to the `env` block of `~/.claude/settings.json`.
   Codex: add the `model_providers` entry and `model_provider` to `~/.codex/config.toml`.
4. If the proxy is down, plain `claude`/`codex` fail — check `scripts/check.sh up`.

## Roll back
Remove the lines added in step 3 (or restore the backups) — tools go back to their own logins. `systemctl --user disable --now llm-proxy`.

## Upgrade
Download the new release asset + `checksums.txt`, verify `sha256sum -c`, replace `bin/`, bump `VERSION`. UI: checkout the new tag in
`~/ref/clones/Cli-Proxy-API-Management-Center`, `bun install --frozen-lockfile && bun run build`, copy `dist/index.html` to `ui/management.html`, bump `ui/VERSION`.

## Other machines later (agent VM, servers)
They cannot reach this localhost. Options: Tailscale (join + set URL, proxy bound to the tailnet address) or an SSH reverse tunnel.
