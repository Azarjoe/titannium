# Titannium — Self-Hosted Infrastructure

Production-inspired self-hosted platform built on Docker, exposed securely to the internet, monitored and version-controlled.

---

## Overview

**Titannium** is an ops-grade self-hosted platform designed to:

- Centralize useful services for personal and family use
- Replace third-party SaaS tools with self-hosted, privacy-respecting alternatives
- Apply real-world infrastructure patterns (reverse proxy, IDS/IPS, monitoring, CI/CD)
- Serve as a scalable foundation for a future private cloud and NAS

---

## System

| Property     | Value            |
|--------------|------------------|
| Hostname     | `nas`            |
| OS           | Ubuntu 24.04 LTS |
| Architecture | x86_64           |
| Storage      | 232GB (LVM)      |
| Access       | SSH + Tailscale  |

---

## Stack

All services run via Docker Compose, exposed through Nginx Proxy Manager with automatic SSL (Let's Encrypt).

### Core Infrastructure

| Service             | Role                           | URL                            |
|---------------------|--------------------------------|--------------------------------|
| Nginx Proxy Manager | Reverse proxy, SSL termination | https://npm.titannium.fr       |
| Homepage            | Centralized dashboard          | https://home.titannium.fr      |
| Portainer           | Docker management interface    | https://portainer.titannium.fr |

### Security

| Service     | Role                                        | Access                     |
|-------------|---------------------------------------------|----------------------------|
| CrowdSec    | IDS/IPS — log analysis, IP banning via CAPI | https://app.crowdsec.net   |
| Tailscale   | Zero-trust private network for SSH access   | Internal only              |
| Vaultwarden | Self-hosted password manager (Bitwarden)    | https://vault.titannium.fr |

### Monitoring & Observability

| Service       | Role                                               | URL                          |
|---------------|----------------------------------------------------|------------------------------|
| Uptime Kuma   | Service availability monitoring, alerting via SMTP | https://kuma.titannium.fr    |
| Grafana       | Metrics and logs visualization                     | https://grafana.titannium.fr |
| Prometheus    | Metrics collection (15 days retention)             | Internal only                |
| Node Exporter | System metrics (CPU, RAM, disk, network)           | Internal only                |
| Loki          | Log aggregation and storage                        | Internal only (port 3100)    |
| Promtail      | Log collector — Docker, NPM and system logs        | Internal only                |

### Tools & Services

| Service         | Role                            | URL                            |
|-----------------|---------------------------------|--------------------------------|
| Password Pusher | Secure one-time secret sharing  | https://secret.titannium.fr    |
| MeTube          | YouTube to MP3/MP4 downloader   | https://ytconvert.titannium.fr |
| Mealie          | Recipe manager and meal planner | https://recettes.titannium.fr  |
| Watchtower      | Automatic image updates (3 AM)  | Internal only                  |

---

## Project Structure

```bash
/srv/docker/
├── docker-compose.yaml         # Global orchestration
├── deploy.sh                   # Multi-domain deployment script (sed-based)
├── .github/workflows/
│   ├── validate.yml            # CI: compose validation, gitleaks, hadolint
│   └── security-scan.yml       # Manual port scan (1-1024) via GitHub Actions
├── security/
│   └── scanner.py              # Custom Python port scanner
├── crowdsec/
│   ├── docker-compose.yml      # Exposes API on 127.0.0.1:8090 for host bouncer
│   └── config/acquis.yaml      # Log sources (SSH, Docker, NPM)
├── homepage/config/            # services.yaml, widgets.yaml, bookmarks.yaml
├── monitoring/
│   ├── docker-compose.yml      # Grafana, Prometheus, Node Exporter, Loki, Promtail
│   ├── prometheus.yml
│   ├── loki-config.yml
│   └── promtail-config.yml     # 3 scrape jobs: docker, varlogs, npm
├── vaultwarden/docker-compose.yml
└── npm/data/logs/              # NPM access logs (shared with CrowdSec + Promtail)
```

---

## CI/CD

### Validation — runs on every push to `main`
- `docker compose config` — validates all compose files
- [Gitleaks](https://github.com/gitleaks/gitleaks) — scans for accidentally committed secrets
- [Hadolint](https://github.com/hadolint/hadolint) — lints Dockerfiles

### Security scan — triggered manually
Custom Python port scanner targeting ports 1-1024 on the public IP. Fails if any port other than 80 and 443 is open. Server IP stored as a GitHub Actions secret.

---

## Security Model

- All services exposed exclusively via HTTPS (Let's Encrypt via NPM)
- No port directly exposed to the internet — all traffic goes through the reverse proxy
- CrowdSec ingests SSH, Docker and NPM logs, shares threat intelligence via CAPI
- iptables bouncer (host systemd service) applies CrowdSec decisions in real time, connecting to the CrowdSec API on `127.0.0.1:8090`
- Remote access via Tailscale — SSH port never visible from the internet
- Vaultwarden with public signups disabled, SMTP invitations only
- Secrets excluded via `.gitignore`, scanned on every push with Gitleaks

> **CrowdSec note:** The agent runs as a Docker container and exposes its API on `127.0.0.1:8090` (internal port 8080 remapped to avoid conflict with NPM). The host bouncer connects to this port to apply iptables DROP rules.

---

## Observability Stack

- **Prometheus** scrapes Node Exporter every 15s for system metrics
- **Promtail** ships logs to Loki via 3 scrape jobs: Docker container logs, NPM access logs, and system logs (`/var/log/`)
- **Loki** stores and indexes logs by label — no full-text indexing
- **Grafana** provides a unified interface for both metrics (Prometheus) and logs (Loki), including a custom **Titannium - Logs** dashboard with real-time panels for Docker, NPM and system logs

---

## Roadmap

- [x] Grafana + Prometheus observability stack
- [x] Loki + Promtail log aggregation + custom dashboard
- [x] Watchtower automatic updates
- [x] Multi-domain deployment script
- [x] Automated security port scan (GitHub Actions)
- [x] Vaultwarden self-hosted password manager
- [x] CrowdSec firewall bouncer operational
- [ ] NAS setup (pending hardware)
- [ ] Nextcloud (pending hardware)
- [ ] Automated backups with Restic
- [ ] CD pipeline — automatic deployment on push

---

## Technical Decisions

**Docker** — Isolation, portability, and reproducibility. Each service is contained — a crash in one doesn't affect the others. The full infrastructure can be rebuilt from compose files in minutes.

**Tailscale over exposed SSH** — Exposing SSH publicly means constant brute force attempts. Tailscale creates a WireGuard tunnel — the port is never visible from the internet.

**CrowdSec over Fail2ban** — Fail2ban is reactive and local. CrowdSec adds community threat intelligence: malicious IPs reported globally are blocked before they reach your server. Its decoupled agent + bouncer architecture mirrors production security patterns.

**Nginx Proxy Manager over raw Nginx** — NPM handles SSL generation, renewal and proxy config through a UI. In a larger context, direct Nginx or Traefik config would give finer control — NPM is the right tradeoff at this scale.

**Grafana + Prometheus over Uptime Kuma alone** — Kuma answers: *is it up?* Prometheus answers: *how much CPU, is memory trending up, is disk running out?* Both layers are necessary for real observability.

**Loki + Promtail** — Logs are the missing layer between uptime and metrics. Loki indexes only labels (not full text), making it lightweight. Grafana queries it via LogQL, giving a single pane of glass for metrics and logs.

**Vaultwarden over a cloud password manager** — Credentials stay local, encrypted, and under your control. Compatible with all official Bitwarden clients with zero vendor dependency.

**Deployment script over env vars** — Docker Compose `.env` substitution only covers compose files. A `sed`-based script handles all file types (YAML, HTML, configs) with zero added dependencies.

**Custom port scanner over nmap** — Zero external dependencies on GitHub Actions runners. Uses `concurrent.futures` + `socket` for parallel scanning, scoped to ports 1-1024 to avoid false positives from ephemeral ports on shared runners.
