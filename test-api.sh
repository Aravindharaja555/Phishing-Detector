#!/usr/bin/env bash
# Quick API smoke tests for the FastAPI backend
set -euo pipefail
BASE="${1:-http://127.0.0.1:5000}"

post() {
  curl -s -X POST "$BASE/api/analyze" -H 'Content-Type: application/json' -d "$1"
}

echo "Health: $(curl -s "$BASE/health")"
echo "Tools: $(curl -s "$BASE/api/tools")"

cases=(
  '{"url":"https://example.com"}'
  '{"url":"http://example.com"}'
  '{"url":"https://8.8.8.8"}'
  '{"url":"https://user@example.com/login"}'
  '{"url":"https://example.com/verify-account"}'
  '{"url":"http://127.0.0.1"}'
  '{"url":"not-a-url"}'
)

for payload in "${cases[@]}"; do
  echo "---- $payload"
  post "$payload" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("verdict") or d.get("error"), d.get("riskScore") or d.get("message",""))'
done
