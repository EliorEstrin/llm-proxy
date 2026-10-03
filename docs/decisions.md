# Decisions (newest last)

| Date | Decision | Why / alternatives |
|---|---|---|
| 2026-10-03 | Use **CLIProxyAPI** (router-for-me, MIT, v8.0.13) as the proxy | Does exactly the job (Claude + Codex OAuth, multi-account routing, management API); building one means owning OAuth/provider-format churn |
| 2026-10-03 | Use it **unmodified**, configure only; no fork now | A fork means merging upstream forever. Escalation order: config → thin layer / own dashboard → fork (MIT, one click later) |
| 2026-10-03 | Run the **release binary**, not a build from source; clone source to `~/ref/clones/CLIProxyAPI` for reading only | Published, checksum-verified artifact; the clone answers unverified questions |
| 2026-10-03 | Take the **no-plugin** build | Smaller surface for a process that holds real login tokens |
| 2026-10-03 | **Localhost only**, no Tailscale yet | All clients are on this machine; Tailscale only adds reachability from other machines |
| 2026-10-03 | Repo location `~/personal/llm-proxy`, local git first | Own tool; remote only on request |
| 2026-10-03 | Secrets in gitignored `.secrets`, config rendered from a template | Config must hold the keys in plain; template keeps them out of git |
| 2026-10-03 | Serve **our own build** of the Management Center UI via `MANAGEMENT_STATIC_PATH`, auto-update off | Upstream otherwise downloads the panel from GitHub at runtime; we want a pinned, built-from-source artifact |
| 2026-10-03 | Tests use **scratch client homes** (`CLAUDE_CONFIG_DIR`, `CODEX_HOME`) and wrapper commands | Prove it without touching the real `/login` |
| 2026-10-03 | Two phases: prove with wrappers, then **cut over** plain `claude`/`codex` | The purpose is migration, wrappers are only the safe test |
| 2026-10-03 | Operator control = enable/disable (and priority) per account via UI, not per-task routing | Owner wants to decide "use this one now, switch later" |
| 2026-10-03 | Existing UI first; build our own page only for gaps | Avoid rebuilding what exists; expected gaps: active-account switch, "is my local connected" |
| 2026-10-03 | Published as a **public** repo on the personal GitHub account (EliorEstrin) | Requested by the owner; contains only config templates, scripts and docs. Secrets, binaries, tokens and the built UI are gitignored; employer/internal references removed before publishing |
