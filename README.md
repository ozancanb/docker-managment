# 🐳 docker-managment

A lightweight collection of Bash scripts to simplify Docker container lifecycle management — from pre-deployment checks to health monitoring.

---

## 📁 Project Structure

```
docker-managment/
├── preflight.sh      # Pre-deployment environment & dependency checks
├── deploy.sh         # Build and deploy Docker containers
├── manage.sh         # Start, stop, restart, and inspect containers
└── healthcheck.sh    # Monitor container health status
```

---

## 🚀 Scripts Overview

### `preflight.sh` — Pre-flight Checks
Validates the environment before any deployment. Checks for required dependencies (e.g., Docker, Docker Compose), verifies config files, and ensures the system is ready to deploy.

```bash
bash preflight.sh
```

---

### `deploy.sh` — Deployment
Handles building Docker images and spinning up containers. Runs `preflight.sh` implicitly to ensure everything is in order before proceeding.

```bash
bash deploy.sh
```

---

### `manage.sh` — Container Management
A general-purpose management script for controlling running containers. Supports operations like start, stop, restart, and status inspection.

```bash
bash manage.sh [start|stop|restart|status]
```

---

### `healthcheck.sh` — Health Monitoring
Checks the health status of running containers and reports any that are unhealthy or stopped unexpectedly.

```bash
bash healthcheck.sh
```

---

## ⚙️ Requirements

- **Docker** `>= 20.x`
- **Docker Compose** `>= 2.x`
- **Bash** `>= 4.x`

---

## 📦 Getting Started

```bash
# Clone the repository
git clone https://github.com/ozancanb/docker-managment.git
cd docker-managment

# Make scripts executable
chmod +x *.sh

# Run pre-flight checks
bash preflight.sh

# Deploy your containers
bash deploy.sh
```

---

## 🔄 Typical Workflow

```
preflight.sh ──► deploy.sh ──► manage.sh ──► healthcheck.sh
    ✅ checks       🚢 deploy     🎛️ control     💓 monitor
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.
