# Titannium — Self-Hosted Infrastructure

Personal self-hosted infrastructure built on Docker, exposed securely to the internet, monitored and version-controlled.

---

## Overview

**Titannium** is a production-grade self-hosted platform designed to:

- Centralize useful services for personal and family use
- Replace third-party SaaS tools with self-hosted, privacy-respecting alternatives
- Apply real-world infrastructure patterns (reverse proxy, IDS/IPS, monitoring, CI/CD)
- Serve as a scalable foundation for a future private cloud and NAS

---

## System

| Property     | Value             |
|--------------|-------------------|
| Hostname     | `nas`             |
| OS           | Ubuntu 24.04 LTS  |
| Architecture | x86_64            |
| Storage      | 232GB (LVM)       |
| Access       | SSH + Tailscale   |

---

## Stack

All services are orchestrated via Docker Compose and exposed through Nginx Proxy Manager with automatic SSL (Let's Encrypt).

### Core Infrastructure

| Service              | Role                              | URL                              |
|----------------------|-----------------------------------|----------------------------------|
| Nginx Proxy Manager  | Reverse proxy, SSL termination    | https://npm.titannium.fr         |
| Homepage             | Centralized dashboard             | https://home.titannium.fr        |
| Portainer            | Docker management interface       | https://portainer.titannium.fr   |

### Security

| Service    | Role                                          | Access                       |
|------------|-----------------------------------------------|------------------------------|
| CrowdSec   | IDS/IPS — log analysis, IP banning via CAPI   | https://app.crowdsec.net     |
| Tailscale  | Zero-trust private network for remote access  | Internal only                |
| NPM        | Access lists, HTTPS enforcement on all routes | https://npm.titannium.fr     |

### Monitoring

| Service      | Role                                        | URL                         |
|--------------|---------------------------------------------|-----------------------------|
| Uptime Kuma  | Service monitoring, alerting via SMTP Gmail | https://kuma.titannium.fr   |

### Tools & Services

| Service          | Role                              | URL                              |
|------------------|-----------------------------------|----------------------------------|
| Password Pusher  | Secure one-time secret sharing    | https://secret.titannium.fr      |
| MeTube           | YouTube to MP3/MP4 downloader     | https://ytconvert.titannium.fr   |
| Mealie           | Recipe manager and meal planner   | https://recettes.titannium.fr    |
| NAS (WIP)        | Future self-hosted storage        | https://nas.titannium.fr         |

---

## Project Structure

```bash
/srv/docker/
├── docker-compose.yaml         # Global orchestration file
├── .github/
│   └── workflows/
│       └── validate.yml        # CI/CD pipeline (GitHub Actions)
├── crowdsec/
│   ├── docker-compose.yml
│   └── config/
│       └── acquis.yaml         # Log sources config (SSH, Docker, NPM)
├── homepage/
│   └── config/
│       ├── services.yaml       # Services displayed on dashboard
│       ├── widgets.yaml        # Widgets (CPU, RAM, weather)
│       └── bookmarks.yaml      # External shortcuts
├── npm/
│   └── data/
│       ├── nginx/              # Proxy host configs
│       └── logs/               # Access and error logs (used by CrowdSec)
├── portainer/
│   └── data/                   # Portainer database and certs
├── mealie/
│   └── data/                   # Recipes, DB, backups
├── metube/
│   └── downloads/              # Downloaded media files
├── pwpush/                     # Password Pusher database
├── uptime-kuma/                # Kuma database and screenshots
└── maintenance/
    └── index.html              # Placeholder page for services in construction
```

---

## CI/CD

Every push to `main` triggers a GitHub Actions pipeline that automatically validates the infrastructure.

### Pipeline jobs

**Validate Docker Compose files**
Runs `docker compose config` on the root `docker-compose.yaml` and all service-level compose files to catch syntax errors before they reach the server.

**Check for hardcoded secrets**
Runs [Gitleaks](https://github.com/gitleaks/gitleaks) across the entire repository to detect any accidentally committed passwords, tokens or API keys.

**Lint Dockerfiles**
Runs [Hadolint](https://github.com/hadolint/hadolint) on any Dockerfile present in the repository to enforce best practices.

The pipeline is defined in `.github/workflows/validate.yml`.

---

## Security model

- All services are exposed exclusively via HTTPS (Let's Encrypt via NPM)
- No service port is directly exposed to the internet — all traffic goes through the reverse proxy
- CrowdSec ingests SSH, Docker and NPM logs and shares threat intelligence via the CAPI network
- An iptables bouncer applies CrowdSec decisions at system level
- Remote access is handled via Tailscale — no VPN port exposed publicly
- Sensitive services are protected by NPM access lists

---

## Roadmap

- [ ] NAS setup (pending hardware)
- [ ] Nextcloud deployment
- [ ] Grafana + Prometheus observability stack
- [ ] Automated backups (Restic)
- [ ] CD pipeline — automatic deployment on push
