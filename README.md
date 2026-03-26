# 🐳 docker-managment

Production-ready Docker Compose deployment ve yönetim scripti koleksiyonu. Preflight kontrollerinden servis sağlık izlemeye kadar tüm deployment sürecini otomatize eder.

---

## 📁 Proje Yapısı

```
docker-managment/
├── deploy.sh          # Tek komutla full production deployment
├── healthcheck.sh     # Container ve HTTPS endpoint sağlık kontrolü
├── manage.sh          # Servis yönetim merkezi (up/down/status/logs...)
└── preflight.sh       # Deployment öncesi 8 adımlı doğrulama
```

> Scriptler `infra/scripts/` dizininde konumlanacak şekilde tasarlanmıştır.

---

## ⚙️ Gereksinimler

- **Docker** `>= 20.x`
- **Docker Compose** `v2.x` (`docker compose` plugin)
- **Bash** `>= 4.x`
- `.env.prod` dosyası (bkz. `.env.prod.example`)
- TLS sertifikaları: `infra/nginx/certs/fullchain.pem` ve `privkey.pem`

---

## 🚀 Hızlı Başlangıç

```bash
# Repoyu klonla
git clone https://github.com/ozancanb/docker-managment.git
cd docker-managment

# Scriptleri çalıştırılabilir yap
chmod +x infra/scripts/*.sh

# Ortam dosyasını oluştur
cp .env.prod.example .env.prod

# Tek komutla deploy et
./infra/scripts/deploy.sh
```

---

## 📜 Scriptler

### `deploy.sh` — Production Deployment

Preflight kontrollerini çalıştırır, servisleri `docker-compose.prod.yml` override'ı ile ayağa kaldırır, 10 saniye bekledikten sonra healthcheck yapar.

```bash
./infra/scripts/deploy.sh
```

**Akış:**
```
preflight.sh → docker compose up -d --build → sleep 10 → healthcheck.sh
```

---

### `preflight.sh` — 8 Adımlı Ön Kontrol

Deployment öncesinde ortamın hazır olduğunu doğrular:

| Adım | Kontrol |
|------|---------|
| 1/8 | `.env.prod` dosyasının varlığı |
| 2/8 | TLS sertifikalarının varlığı (`fullchain.pem`, `privkey.pem`) |
| 3/8 | Docker Compose kurulumu |
| 4/8 | 80 ve 443 portlarının müsaitliği |
| 5/8 | Disk alanı (`df -h`) |
| 6/8 | Bellek durumu (`free -h`) |
| 7/8 | `docker compose config` doğrulaması |
| 8/8 | Nginx syntax kontrolü (compose network içinde) |

```bash
./infra/scripts/preflight.sh
```

---

### `manage.sh` — Servis Yönetimi

Tüm günlük operasyonlar için tek giriş noktası.

```bash
./infra/scripts/manage.sh <komut> [servis_adı]
```

| Komut | Açıklama |
|-------|----------|
| `up` | Servisleri başlat (`-d`) |
| `down` | Servisleri durdur ve temizle |
| `build` | Tüm imajları `--no-cache` ile yeniden derle |
| `deploy` | Orphan'ları kaldır, sıfırdan ayağa kaldır |
| `update <servis>` | Tek bir servisi yeniden deploy et |
| `status` | Container durumu, CPU/RAM kullanımı ve endpoint sağlığı |
| `service <servis>` | Servis detayı: durum + son 20 log + env değişkenleri |
| `logs` | Tüm servislerin canlı log akışı |

**Desteklenen servisler:** `nginx`, `web`, `api`, `workers`, `ollama`, `postgres`, `redis`, `clickhouse`

#### Örnekler

```bash
# Sistemi başlat
./infra/scripts/manage.sh up

# Genel durum özeti (container, CPU/RAM, endpoint kontrolü)
./infra/scripts/manage.sh status

# Sadece API servisini yeniden deploy et
./infra/scripts/manage.sh update api

# API servisinin loglarına ve env'ine bak
./infra/scripts/manage.sh service api

# Canlı log izleme
./infra/scripts/manage.sh logs
```

---

### `healthcheck.sh` — Sağlık Kontrolü

Container durumlarını listeler ve `https://localhost/health` endpoint'ini doğrular.

```bash
./infra/scripts/healthcheck.sh
```

> `curl -kfsS` ile self-signed sertifikalı ortamlarda da çalışır.

---

## 🔄 Deployment Akışı

```
.env.prod + TLS certs
        │
        ▼
  preflight.sh  ──► 8 kontrol geçilmezse EXIT
        │
        ▼
  docker compose up -d --build
  (docker-compose.yml + docker-compose.prod.yml)
        │
        ▼
     sleep 10
        │
        ▼
  healthcheck.sh  ──► /health endpoint OK?
        │
        ▼
   ✅ Deploy tamamlandı
```

---

## 🤝 Katkıda Bulunma

Pull request'ler memnuniyetle karşılanır. Büyük değişiklikler için önce bir issue açmanız önerilir.

---

## 📄 Lisans

Bu proje açık kaynaklıdır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.
