#!/usr/bin/env bash
set -euo pipefail

# Değişkenler
ENV_FILE=".env.prod"
COMPOSE_FILES="-f docker-compose.yml -f docker-compose.prod.yml"

# .env kontrolü
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Hata: $ENV_FILE bulunamadı! Lütfen .env.prod.example dosyasından oluşturun."
    exit 1
fi

case "${1:-}" in
    up)
        echo "🚀 Sistem ayağa kaldırılıyor..."
        docker compose --env-file $ENV_FILE $COMPOSE_FILES up -d
        ;;
    
    down)
        echo "🛑 Sistem durduruluyor ve temizleniyor..."
        docker compose --env-file $ENV_FILE $COMPOSE_FILES down
        ;;

    build)
        echo "🛠️ Konteynerlar yeniden inşa ediliyor (no-cache)..."
        docker compose --env-file $ENV_FILE $COMPOSE_FILES build --no-cache
        ;;

    deploy)
        echo "🔄 Full Deployment başlatılıyor..."
        docker compose --env-file $ENV_FILE $COMPOSE_FILES down --remove-orphans
        docker compose --env-file $ENV_FILE $COMPOSE_FILES up -d --build
        echo "✅ Deployment tamamlandı."
        ;;

    status)
        echo "📊 Sistem Durum Özeti..."
        echo "----------------------------------------------------------"
        # Konteyner durumlarını ve sağlık bilgisini gösterir
        docker compose --env-file $ENV_FILE $COMPOSE_FILES ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        echo -e "\n📈 Kaynak Kullanımı (CPU/RAM)..."
        echo "----------------------------------------------------------"
        # Sadece çalışan projenin konteynerlarının stats bilgisini çeker
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        
        echo -e "\n🔍 Önemli Endpoint Kontrolleri..."
        echo "----------------------------------------------------------"
        # API Health Check
        if curl -skf http://localhost/api/health > /dev/null; then
            echo "✅ API (Nginx üzerinden): Erişilebilir"
        else
            echo "❌ API (Nginx üzerinden): ERİŞİLEMİYOR"
        fi

        # Ollama Check
        if docker exec saas-ollama ollama list > /dev/null 2>&1; then
            echo "✅ Ollama Engine: Hazır"
        else
            echo "❌ Ollama Engine: Sorunlu"
        fi
        ;;        

    update)
        SERVICE_NAME="${2:-}"
        if [ -z "$SERVICE_NAME" ]; then
            echo "❓ Kullanım: $0 service [servis_adi]"
            echo "Örn: $0 service api"
            echo "Mevcut servisler: nginx, web, api, workers, ollama, postgres, redis, clickhouse"
            exit 1
        fi
        echo "🔄 Full Deployment başlatılıyor..."
        docker compose --env-file $ENV_FILE $COMPOSE_FILES down --remove-orphans $SERVICE_NAME
        docker compose --env-file $ENV_FILE $COMPOSE_FILES up -d --build $SERVICE_NAME
        echo "✅ Deployment tamamlandı."
        ;;

    service)
        SERVICE_NAME="${2:-}"
        if [ -z "$SERVICE_NAME" ]; then
            echo "❓ Kullanım: $0 service [servis_adi]"
            echo "Örn: $0 service api"
            echo "Mevcut servisler: nginx, web, api, workers, ollama, postgres, redis, clickhouse"
            exit 1
        fi
        
        echo "🔍 Servis Detayları: $SERVICE_NAME"
        echo "----------------------------------------------------------"
        # Servisin anlık durumunu gösterir
        docker compose --env-file $ENV_FILE $COMPOSE_FILES ps $SERVICE_NAME
        
        echo -e "\n📝 Son 20 Log Satırı:"
        echo "----------------------------------------------------------"
        docker compose --env-file $ENV_FILE $COMPOSE_FILES logs --tail=20 $SERVICE_NAME
        
        echo -e "\n⚙️ Konfigürasyon (Environment):"
        echo "----------------------------------------------------------"
        docker exec saas-$SERVICE_NAME env | grep -E "NODE_ENV|APP_|DB_|OLLAMA|POSTGRES" || echo "Env okunamadı."
        ;;

    logs)
        echo "📝 Loglar izleniyor (Ctrl+C ile çıkın)..."
        docker compose --env-file $ENV_FILE $COMPOSE_FILES logs -f
        ;;

    *)
        echo "Kullanım: $0 {up|down|build|deploy|logs|status}"
        exit 1
        ;;
esac