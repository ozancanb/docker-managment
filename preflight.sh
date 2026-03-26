#!/usr/bin/env bash
set -euo pipefail

echo "[1/8] .env.prod kontrolü"
test -f .env.prod

echo "[2/8] TLS sertifikalari kontrolü"
test -f infra/nginx/certs/fullchain.pem
test -f infra/nginx/certs/privkey.pem

echo "[3/8] Docker Compose kontrolü"
docker compose version >/dev/null

echo "[4/8] Port kontrolü"
if ss -ltn | grep -q ':80 '; then
  echo "Port 80 kullanimda"
  exit 1
fi
if ss -ltn | grep -q ':443 '; then
  echo "Port 443 kullanimda"
  exit 1
fi

echo "[5/8] Disk alani"
df -h .

echo "[6/8] Bellek"
free -h

echo "[7/8] Compose config dogrulama"
docker compose \
  --env-file .env.prod \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  config >/dev/null

echo "[8/8] Nginx syntax kontrolü (compose network içinde)"
docker compose \
  --env-file .env.prod \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  up -d api web

docker compose \
  --env-file .env.prod \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  run --rm nginx nginx -t

echo "Preflight basarili."