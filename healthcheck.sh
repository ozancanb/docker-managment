#!/usr/bin/env bash
set -euo pipefail

echo "Container durumları kontrol ediliyor..."
docker compose \
  --env-file .env.prod \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  ps

echo "HTTPS health endpoint kontrol ediliyor..."
curl -kfsS https://localhost/health >/dev/null

echo "Healthcheck başarılı."