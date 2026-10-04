#!/usr/bin/env bash
# Installs and starts the user service. Run only after test-plan checks 3-7 pass (see docs/runbook.md).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p ~/.config/systemd/user
cp "$ROOT/systemd/llm-proxy.service" "$ROOT/systemd/llm-proxy-unstick.service" ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now llm-proxy.service llm-proxy-unstick.service
systemctl --user --no-pager status llm-proxy.service llm-proxy-unstick.service | grep -E '●|Active'
