# dashboard (only if the stock UI falls short)

Plan if needed: a tiny local server + one HTML page. The server holds the management key and calls the proxy's management API;
the page shows per-account usage/quota, an operator "active account" switch (enable/disable via `PATCH /auth-files/status`) and
a "connected" indicator (recent requests per client). Decide after `docs/test-plan.md` check 8 and a look at the stock UI.
