#!/usr/bin/env bash
# unstick.sh [--once] — clears false "model not found" lockouts. Never prints keys.
#
# Why: the proxy puts a model on a 12 h cooldown for an account on ANY upstream 404. Anthropic also answers 404
# (thread_not_found) when Claude Code continues a conversation whose server-side thread lives elsewhere — a
# request problem, not a missing model. The proxy then tries the next account, gets the same 404, and the model is
# dead on every account until the cooldown ends (instant 503 auth_unavailable). Upstream has an exception for the
# OpenAI equivalent only (internal/clienterror IsItemNotPersisted, v8.0.13).
#
# What: every $UNSTICK_INTERVAL seconds, any 404 cooldown is reset via the management API
# (POST /v8/management/routing/cooldown/reset). The cooldown record does not say which 404 it was, and a model locked
# on every account also drops out of /v1/models, so all 404s are reset: a truly unknown model just costs one more
# upstream 404 (a real "not found" instead of a misleading 503). The endpoint resets every cooldown on the account,
# so a real 429 there is forgotten too; the next request re-learns it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL="${LLM_PROXY_URL:-http://127.0.0.1:8317}"
INTERVAL="${UNSTICK_INTERVAL:-10}"
get() { sed -n "s/^$1=//p" "$ROOT/.secrets"; }

tick() {
  local MK files
  MK="$(get MGMT_SECRET)"
  files=$(curl -sf -m 10 -H "Authorization: Bearer $MK" "$URL/v0/management/auth-files") || return 0   # proxy down
  FILES="$files" python3 -c '
import json, os
for f in json.loads(os.environ["FILES"]).get("files", []):
    stuck = [c.get("model_key") or "*" for c in f.get("cooldowns") or [] if c.get("http_status") == 404]
    if stuck:
        print(f["auth_index"], f.get("label") or f.get("name"), ",".join(stuck))
' | while read -r idx who stuck; do
    r=$(curl -s -m 10 -X POST -H "Authorization: Bearer $MK" -H 'content-type: application/json' \
      -d "{\"auth_index\":\"$idx\"}" "$URL/v8/management/routing/cooldown/reset")
    echo "unstuck $who ($stuck): $r"
  done
}

[ "${1:-}" = --once ] && { tick; exit 0; }
echo "watching $URL every ${INTERVAL}s"
while true; do tick || true; sleep "$INTERVAL"; done
