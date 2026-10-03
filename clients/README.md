# clients — pointing a tool at the proxy

`claude-proxy` and `codex-proxy` start the normal tool with the proxy URL and the placeholder client key. They are the
**phase-1 test** commands; plain `claude`/`codex` are unchanged until the cutover (`docs/runbook.md`).

- Default = scratch homes (`~/.local/share/llm-proxy/{claude-home,codex-home}`): the real login is untouched.
- `LLM_PROXY_REAL_HOME=1` = use the real config dir, still through the proxy.
- `LLM_PROXY_URL` overrides the proxy address (e.g. a tailnet address later).
- Keys are read from `../.secrets` inside the script (client key only) and never printed.
- Claude: `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` (docs-verified), isolation via `CLAUDE_CONFIG_DIR` (docs-verified).
- Codex: `model_providers` + `env_key` + `model_provider` (verified in Codex source), isolation via `CODEX_HOME`.
- **Untested until an account is logged in.**
