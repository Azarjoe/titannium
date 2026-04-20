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

| Service       | Role                                          | Access                       |
|---------------|-----------------------------------------------|------------------------------|
| CrowdSec      | IDS/IPS — log analysis, IP banning via CAPI   | https://app.crowdsec.net     |
| Tailscale     | Zero-trust private network for remote access  | Internal only                |
| NPM           | Access lists, HTTPS enforcement on all routes | https://npm.titannium.fr     |
| Vaultwarden   | Self-hosted password manager (Bitwarden)      | https://vault.titannium.fr   |

### Monitoring & Observability

| Service        | Role                                               | URL                          |
|----------------|----------------------------------------------------|------------------------------|
| Uptime Kuma    | Service availability monitoring, alerting via SMTP | https://kuma.titannium.fr    |
| Grafana        | Metrics visualization and dashboards               | https://grafana.titannium.fr |
| Prometheus     | Metrics collection and storage (15 days retention) | Internal only                |
| Node Exporter  | System metrics exposure (CPU, RAM, disk, network)  | Internal only                |

### Tools & Services

| Service          | Role                              | URL                              |
|------------------|-----------------------------------|----------------------------------|
| Password Pusher  | Secure one-time secret sharing    | https://secret.titannium.fr      |
| MeTube           | YouTube to MP3/MP4 downloader     | https://ytconvert.titannium.fr   |
| Mealie           | Recipe manager and meal planner   | https://recettes.titannium.fr    |
| NAS (WIP)        | Future self-hosted storage        | https://nas.titannium.fr         |

### Automation

| Service     | Role                                              | Access        |
|-------------|---------------------------------------------------|---------------|
| Watchtower  | Automatic Docker image updates (daily at 3:00 AM) | Internal only |

---

## Project Structure

```bash
/srv/docker/
├── docker-compose.yaml         # Global orchestration file
├── deploy.sh                   # Deployment script for multi-domain support
├── .github/
│   └── workflows/
│       ├── validate.yml        # CI pipeline — runs on every push
│       └── security-scan.yml   # Manual security port scan
├── security/
│   └── scanner.py              # Custom Python port scanner (concurrent.futures + socket)
├── crowdsec/
│   ├── docker-compose.yml
│   └── config/
│       └── acquis.yaml         # Log sources config (SSH, Docker, NPM)
├── homepage/
│   └── config/
│       ├── services.yaml       # Services displayed on dashboard
│       ├── widgets.yaml        # Widgets (CPU, RAM, weather)
│       └── bookmarks.yaml      # External shortcuts
├── monitoring/
│   ├── docker-compose.yml      # Grafana, Prometheus, Node Exporter
│   └── prometheus.yml          # Scrape config
├── vaultwarden/
│   └── docker-compose.yml      # Vaultwarden password manager
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

## Deployment

To deploy this infrastructure on a new machine with a different domain:

```bash
git clone https://github.com/Azarjoe/titannium.git
cd titannium
./deploy.sh
```

The script prompts for a domain name and automatically replaces all references throughout the configuration files before starting the services.

> Note: After running the script, configure DNS records, set up proxy hosts in Nginx Proxy Manager, and provide secrets manually.

---

## CI/CD

### Validation pipeline — runs on every push to `main`

- `docker compose config` validates all compose files for syntax errors
- [Gitleaks](https://github.com/gitleaks/gitleaks) scans the repository for accidentally committed secrets
- [Hadolint](https://github.com/hadolint/hadolint) lints any Dockerfile present

### Security scan — triggered manually

A custom Python port scanner scans all well-known ports (1-1024) of the public IP and fails if any port other than 80 and 443 is open. The scan is limited to 1-1024 to avoid false positives from ephemeral ports generated by GitHub Actions runners. The server IP is stored as a GitHub Actions secret.

---

## Security model

- All services exposed exclusively via HTTPS (Let's Encrypt via NPM)
- No port directly exposed to the internet — all traffic goes through the reverse proxy
- CrowdSec ingests SSH, Docker and NPM logs, shares threat intelligence via CAPI
- An iptables bouncer applies CrowdSec decisions at system level
- Remote access via Tailscale — no VPN port exposed publicly
- Sensitive services protected by NPM access lists
- Vaultwarden self-hosted with SMTP invitations, public signups disabled
- Public exposure verified via automated port scan from GitHub Actions

---

## Roadmap

- [ ] NAS setup (pending hardware)
- [ ] Nextcloud deployment (pending hardware)
- [x] Grafana + Prometheus observability stack
- [x] Watchtower automatic updates
- [x] Multi-domain deployment script
- [x] Automated security port scan (GitHub Actions)
- [x] Vaultwarden self-hosted password manager
- [ ] Automated backups (Restic)
- [ ] CD pipeline — automatic deployment on push

---

## Technical decisions

### Why Docker?
Isolation, portability, reproducibility, and simplified updates. Each service runs in its own container — a crash or misconfiguration in one does not affect the others. The entire infrastructure is described in compose files and can be rebuilt on a new machine in minutes.

---

### Why Tailscale over exposing SSH directly?
Exposing SSH publicly means constant brute force attempts. Tailscale creates an encrypted WireGuard tunnel — the SSH port is never visible from the internet. A closed port cannot be attacked.

---

### Why CrowdSec over Fail2ban?
Fail2ban is reactive and local. CrowdSec adds community threat intelligence — malicious IPs reported by thousands of servers worldwide are blocked before they ever reach yours. Its decoupled architecture (agent + bouncer) mirrors patterns used in production security infrastructure.

---

### Why Nginx Proxy Manager over raw Nginx?
NPM handles SSL generation, renewal and proxy configuration through a UI, reducing operational overhead significantly. In an enterprise context, direct Nginx or Traefik configuration would give finer control — NPM is the right tool for this scale.

---

### Why Grafana + Prometheus over Uptime Kuma alone?
Uptime Kuma answers: is the service up? Grafana + Prometheus answer: how much CPU, is memory trending up, is disk running out? The two tools are decoupled and mirror the observability stack used in most production cloud environments.

---

### Why Vaultwarden over a cloud password manager?
Cloud password managers store credentials on third-party servers. Vaultwarden is a self-hosted Bitwarden-compatible server — credentials are encrypted and stored locally. Compatible with all official Bitwarden clients (mobile, desktop, browser extension) with zero vendor dependency.

---

### Why Watchtower?
Manual image updates are error-prone and easy to forget. Watchtower runs every night at 3:00 AM, pulls new image versions, recreates containers, and removes old images automatically — zero manual intervention.

---

### Why a deployment script over environment variables?
Docker Compose `.env` substitution only works for compose files. Homepage, Mealie and other services use plain YAML that does not support interpolation. A `sed`-based script covers all file types uniformly with zero added dependencies.

---

### Why a custom port scanner over nmap?
Zero external dependencies — Python is already available on every GitHub Actions runner. The scanner uses `concurrent.futures` and `socket` for parallel scanning. Scoped to ports 1-1024 to avoid false positives from ephemeral ports on shared runners. A full scan would require a self-hosted runner with a static IP.
