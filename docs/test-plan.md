# Test plan — how we know it works

Run in order; a layer only counts if the previous one passed. The proxy's own counters are the proof.

| # | Check | How | Pass looks like | Result |
|---|---|---|---|---|
| 1 | Proxy is up | `scripts/check.sh up` | port answers; 401 without key, 200 with | passed 2026-10-03 |
| 2 | Accounts are in | `scripts/check.sh accounts` | all logged-in accounts listed, active | |
| 3 | Direct request works | `scripts/check.sh direct claude` / `direct codex` | a real model answer from each provider | |
| 4 | Claude Code through proxy | `claude-proxy -p "say hi"` | answers; that account's request count +1 | |
| 5 | Codex through proxy | `codex-proxy exec "say hi"` | answers; that account's request count +1 | |
| 6 | Control works | switch the active Claude account in the UI, repeat 4 | the other account's count rises | |
| 7 | Failure is visible | stop the proxy, run 4 | tool fails clearly, no silent fallback to the old login | |
| 8 | Data is enough for a dashboard | dump `GET /auth-files` into `findings/` | note what Claude/Codex report (quota? tokens?) | |

Known risks to watch: Codex streaming through the proxy; Claude quota may not be reported; the wrapper's scratch Claude home
may ask for onboarding; default Codex model naming vs what the proxy exposes.
