#!/usr/bin/env bash
# Start the proxy. Usage: ./run.sh [extra proxy flags, e.g. -claude-login]
set -euo pipefail
cd "$(dirname "$0")"
[ -f .secrets ] || { umask 077; printf 'MGMT_SECRET=%s\nPROXY_API_KEY=%s\n' "$(openssl rand -hex 24)" "sk-local-$(openssl rand -hex 24)" > .secrets; echo "generated .secrets"; }
set -a; . ./.secrets; set +a
umask 077
sed -e "s|@MGMT_SECRET@|$MGMT_SECRET|" -e "s|@PROXY_API_KEY@|$PROXY_API_KEY|" config.yaml.tmpl > config.yaml
export MANAGEMENT_STATIC_PATH="$PWD/ui/management.html"
exec ./bin/cli-proxy-api -config ./config.yaml "$@"
