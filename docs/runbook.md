# Runbook

## Set up on a new machine
Git carries only code and docs. The binary, the UI build, `.secrets` and the logins are per machine. Clone to
`~/personal/llm-proxy`: the systemd unit and the wrappers expect that path.

```
git clone git@github.com:EliorEstrin/llm-proxy.git ~/personal/llm-proxy && cd ~/personal/llm-proxy

# proxy binary: pinned release, checksum-verified (version in VERSION)
mkdir -p bin && cd bin
gh release download v8.0.13 -R router-for-me/CLIProxyAPI -p checksums.txt -p 'CLIProxyAPI_8.0.13_linux_amd64_no-plugin.tar.gz'
grep linux_amd64_no-plugin checksums.txt | sha256sum -c - && tar -xzf CLIProxyAPI_8.0.13_linux_amd64_no-plugin.tar.gz
cd ..

# UI: built from source at the pinned tag (version in ui/VERSION)
gh repo clone router-for-me/Cli-Proxy-API-Management-Center ~/ref/clones/Cli-Proxy-API-Management-Center
(cd ~/ref/clones/Cli-Proxy-API-Management-Center && git checkout v1.25.3 && bun install --frozen-lockfile && bun run build)
cp ~/ref/clones/Cli-Proxy-API-Management-Center/dist/index.html ui/management.html

# wrappers on PATH
ln -sf "$PWD/clients/claude-proxy" ~/.local/bin/claude-proxy
ln -sf "$PWD/clients/codex-proxy"  ~/.local/bin/codex-proxy

# service (first start generates this machine's own .secrets), then logins
scripts/install-service.sh && scripts/check.sh up
./run.sh -claude-login          # once per Claude account
./run.sh -codex-device-login
scripts/check.sh accounts
```

Logging in while the service runs is fine: the login is its own short process and the running proxy picks up the new
credential file. Each machine's proxy is independent, with its own keys and UI. Keep each account on one proxy
until open question 14 is answered. After a `git pull` that bumps `VERSION` or `ui/VERSION`, redo that step and
`systemctl --user restart llm-proxy`.

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
