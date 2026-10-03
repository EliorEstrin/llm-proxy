# Goal

## The problem
Today every machine and tool logs in to Claude and Codex by itself (`/login`, `codex login`, device-code logins, setup tokens).
There is no single place to see which subscription is used, how much of it is left, or to switch which
account is active. Each login lives wherever the tool runs.

## The end goal
One **central authenticated place** on my machine — a proxy that is the only thing logged in to the providers — plus a
**UI where I, the operator, decide**:

1. **Which account is active.** "For now use Claude account A", then later "switch to B". One click, applies to every
   tool at once. This is operator control, not per-task routing.
2. **What is connected.** Is the proxy up, and is my local Claude Code / Codex actually going through it (recent requests).
3. **How much each subscription has.** Per account: plan/limit window, usage, reset time, failures, cooldown.
4. **Later:** extra logic (auto-prefer the account that resets soonest, alerts), and other machines (agent VM, servers)
   pointing at the same proxy over a private network.

## My subscriptions (as stated)
Two Claude Code accounts and one Codex account. Not yet confirmed whether the Claude ones are separate paid subscriptions.

## Scope and non-goals
- Local first: proxy listens on 127.0.0.1. No Tailscale needed until another machine must reach it.
- Not building a proxy from scratch, not forking (see decisions).
- Applications that use env-var tokens are out of scope: only the agent CLIs (Claude Code, Codex).
- Provider-terms/ban risk was raised and consciously accepted by the owner; source IP changes from per-machine to one.

## Done means
Plain `claude` and `codex` on this workstation go through the proxy permanently (systemd service), the UI shows live
accounts/usage/connection, and switching the active account from the UI changes which account serves the next request.
