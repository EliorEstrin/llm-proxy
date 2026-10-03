#!/usr/bin/env bash
# check.sh up|accounts|models|direct <claude|codex> — verification helper. Never prints keys.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL="${LLM_PROXY_URL:-http://127.0.0.1:8317}"
get() { sed -n "s/^$1=//p" "$ROOT/.secrets"; }
CK="$(get PROXY_API_KEY)"; MK="$(get MGMT_SECRET)"
case "${1:-}" in
  up)
    a=$(curl -s -o /dev/null -w '%{http_code}' "$URL/v1/models" || true)
    b=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $CK" "$URL/v1/models" || true)
    echo "no key: $a (want 401) | with client key: $b (want 200)"
    [ "$a" = 401 ] && [ "$b" = 200 ] && echo "UP" || { echo "NOT OK"; exit 1; } ;;
  accounts)
    curl -s -H "Authorization: Bearer $MK" "$URL/v0/management/auth-files" |
      python3 -c 'import sys,json; d=json.load(sys.stdin); fs=d.get("files",[]); print(len(fs),"account(s)")
for f in fs: print("-",f.get("provider"),f.get("label") or f.get("name"),"status=",f.get("status"),"disabled=",f.get("disabled"),"ok/fail=",f.get("success"),"/",f.get("failed"))' ;;
  models)
    curl -s -H "Authorization: Bearer $CK" "$URL/v1/models" | python3 -c 'import sys,json; [print(m["id"]) for m in json.load(sys.stdin).get("data",[])]' ;;
  direct)
    kind="${2:?claude|codex}"
    case "$kind" in
      claude) m=$("$0" models | grep -i -m1 claude); echo "model: $m"
        curl -s "$URL/v1/messages" -H "x-api-key: $CK" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
          -d "{\"model\":\"$m\",\"max_tokens\":32,\"messages\":[{\"role\":\"user\",\"content\":\"say hi\"}]}" ;;
      codex) m=$("$0" models | grep -i -E 'gpt|codex' | grep -v -i -E 'image|review' | head -1); echo "model: $m"  # image models only serve /v1/images
        curl -s "$URL/v1/chat/completions" -H "Authorization: Bearer $CK" -H "content-type: application/json" \
          -d "{\"model\":\"$m\",\"max_tokens\":32,\"messages\":[{\"role\":\"user\",\"content\":\"say hi\"}]}" ;;
      *) echo "claude|codex"; exit 2 ;;
    esac; echo ;;
  *) echo "usage: check.sh up|accounts|models|direct <claude|codex>"; exit 2 ;;
esac
