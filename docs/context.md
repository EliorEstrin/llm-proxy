# Context and sources

- **Origin:** Theo (t3.gg), "If you have a Claude sub, watch this" — https://youtu.be/D8PikZ1KhUo (proxy at 15:11–26:11, Tailscale 22:06–25:00).
  Transcript saved locally in `~/transcripts/`. He runs "CLI Proxy API" (a fork he calls "Vibe proxy"), many Claude/Codex accounts, over Tailscale.
- **Proxy:** https://github.com/router-for-me/CLIProxyAPI (MIT). Reference clone `~/ref/clones/CLIProxyAPI`.
- **UI:** https://github.com/router-for-me/Cli-Proxy-API-Management-Center (MIT, v1.25.3). Reference clone `~/ref/clones/Cli-Proxy-API-Management-Center`.
- **Related upstream tools:** CLIProxyAPI Quota Inspector (AllenReder), cc-status-line, cliproxyapi-dashboard (itsmylife44, Next.js+Postgres, team-oriented).
- **Claude Code gateway docs:** https://code.claude.com/docs/en/llm-gateway-connect · **Codex:** https://github.com/openai/codex
- **Visual explanation (diagrams):** Claude Docs artifact "CLI Proxy + Tailscale: one front door for many AI subscriptions"
  — https://claude.ai/code/artifact/5148e3f6-0537-473d-a623-cc8be136c6d6
- **Today's logins (for contrast, not proxied):** the workstation uses `/login` and `~/.codex/auth.json`; a remote agent VM logs in by itself (a setup token for Claude, a device-code login for Codex). No proxy exists anywhere else yet.
