# Open questions (unverified)

1. Are the two Claude accounts separate paid subscriptions, or is one API-only? (decides what there is to balance)
2. Does logging an account into the proxy affect that account's existing `/login` on this machine? (test with the least important account first)
3. Does the proxy report **Claude** subscription quota (5h/7d)? Confirmed for Codex only.
4. Exact field names for **priority** on OAuth credentials (only `weight` confirmed). Is `fill-first` + priority enough for "primary/backup"?
5. Does the stock UI have an **active-account switch** and a **"is my local connected"** view? If not, build `dashboard/`.
6. Does Codex stream correctly through the proxy; which model names does it expose (default model in the owner's config is not a stock name)?
7. Will a scratch `CLAUDE_CONFIG_DIR` run without an onboarding/login prompt when `ANTHROPIC_AUTH_TOKEN` is set?
8. Is the upstream `management.html` release asset equivalent to our source build? (we serve our own build; not compared)
9. The proxy has "cloaking" settings (`disable-claude-cloak-mode`, `disable-codex-cloaking`): what do they change about how requests look to the providers, and are they on by default? Read the source before relying on the proxy.
10. Source IP: the proxy's requests leave from the host machine's public IP (this workstation, same as plain `claude`/`codex` today). Decide later whether other machines (e.g. an agent VM) should route through it, which would put them on that IP too.
