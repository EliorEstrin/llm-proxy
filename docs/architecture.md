# Architecture

```
claude / codex  ──(URL + placeholder key)──►  proxy (127.0.0.1:8317)  ──(real OAuth token)──►  Anthropic / OpenAI
                                                 │  ▲
                                   routing rules │  │ management API (needs MGMT key)
                                                 ▼  │
                                      ~/.cli-proxy-api (one credential file per account)
                                                    ▲
                              management UI (ui/management.html, served at /management.html)
```

## Components
| Piece | What | Where |
|---|---|---|
| Proxy | CLIProxyAPI v8 (Go, MIT), pinned release, no-plugin build | `bin/cli-proxy-api`, version in `VERSION` |
| Config | Template rendered with secrets by `run.sh` | `config.yaml.tmpl` → `config.yaml` (gitignored) |
| Credentials | One file per logged-in account, owned by the proxy | `~/.cli-proxy-api/` (outside repo, mode 700) |
| UI | Upstream "Management Center" built from source, single HTML file | `ui/management.html` |
| Clients | Claude Code, Codex pointed at the proxy | `clients/` wrappers now; tool config at cutover |

## How a client is pointed at the proxy (login vs proxy)
- **Today** (`/login`): the tool holds a real token and talks to the provider.
- **With the proxy:** the tool holds only the proxy URL and a placeholder key; the proxy holds the real tokens, refreshes
  them, picks an account per request, forwards with that account's token.
- Claude Code: `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` (verified in Claude docs). Setting only the base URL keeps the saved
  login; setting the auth token turns subscription login off for that session.
- Codex: `[model_providers.x]` with `base_url`, `wire_api`, `env_key` and `model_provider = "x"` (verified in Codex source/docs).
- Isolation for tests: `CLAUDE_CONFIG_DIR` (Claude docs) and `CODEX_HOME` (Codex source) give scratch homes so the real login is untouched.

## Operator control (the levers, from the proxy's source/config)
| Lever | Effect |
|---|---|
| Enable/disable an account | Management API `PATCH /auth-files/status`; removes it from use |
| Routing strategy | `round-robin`, `weighted-round-robin`, `fill-first` (`routing.strategy`) |
| Weight / priority | Per credential; `weight` field on OAuth auth JSON confirmed, `priority` on OAuth files unverified |
| Model prefix | `prefix/model` forces a specific credential (not needed for operator control) |
| Session affinity | On: a conversation sticks to one account (prompt cache); if its account becomes unavailable it fails over |
| Cooldown/retry | 429/5xx marks the account cooling down and retries another |

## Visibility (management API, from source)
- `GET /v0/management/auth-files`: per account status, success/failed counts, recent requests, `quota` observation, `model_quotas`.
- `GET /usage-queue`: token consumption monitoring. A quota Inspector/dashboard exist upstream (see context).
- Codex quota (5h/7d) is provider-reported (websocket `codex.rate_limits`, `/wham/usage`). **Claude quota reporting is unverified.**
- Two kinds of data: *measured by the proxy* (requests, tokens, 429s — reliable) vs *reported by the provider* (quota windows).

## Security model (local)
- Listens on `127.0.0.1` only; management `allow-remote: false`; client requests need the proxy key (`access.api-keys`).
- Management UI/API need the management key. The bundled panel is **not** downloaded from GitHub: we serve our own build via
  `MANAGEMENT_STATIC_PATH`, auto-update disabled.
- The proxy still fetches model lists from `raw.githubusercontent.com` at start (not the panel).
- Real tokens: `~/.cli-proxy-api` must stay owner-only. Remote access later = Tailscale (identity-gated, no key on the proxy) or an SSH tunnel.

## Extension path
1. Config rules (free, upgrade-safe) → 2. a thin layer/our own dashboard calling the management API (`dashboard/`) → 3. fork only if 1+2 cannot do it.
A visual walkthrough (diagrams) of all this lives in the Claude Docs artifact linked from `context.md`.
