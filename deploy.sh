#!/usr/bin/env bash
set -euo pipefail

./infra/scripts/preflight.sh

echo "Servisler ayağa kaldırılıyor..."
docker compose \
  --env-file .env.prod \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  up -d --build

echo "Servislerin hazır olması bekleniyor..."
sleep 10

./infra/scripts/healthcheck.sh

echo "Deploy tamamlandı."