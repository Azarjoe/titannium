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
│   └── scanner.py              # Custom Python port scanner (asyncio + multithreading)
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

The script will prompt for a domain name and automatically replace all references throughout the configuration files before starting the services.

> Note: After running the script, configure your DNS records and set up proxy hosts in Nginx Proxy Manager manually.

---

## CI/CD

### Validation pipeline — runs on every push to `main`

**Validate Docker Compose files**
Runs `docker compose config` on the root `docker-compose.yaml` and all service-level compose files to catch syntax errors before they reach the server.

**Check for hardcoded secrets**
Runs [Gitleaks](https://github.com/gitleaks/gitleaks) across the entire repository to detect any accidentally committed passwords, tokens or API keys.

**Lint Dockerfiles**
Runs [Hadolint](https://github.com/hadolint/hadolint) on any Dockerfile present in the repository to enforce best practices.

### Security scan — triggered manually

A custom Python port scanner built with `concurrent.futures` and `socket` scans all 65535 ports of the public IP. The pipeline fails if any port other than 80 and 443 is detected as open — ensuring no service is accidentally exposed to the internet.

The server IP is stored as a GitHub Actions secret and never hardcoded in the repository.

---

## Security model

- All services are exposed exclusively via HTTPS (Let's Encrypt via NPM)
- No service port is directly exposed to the internet — all traffic goes through the reverse proxy
- CrowdSec ingests SSH, Docker and NPM logs and shares threat intelligence via the CAPI network
- An iptables bouncer applies CrowdSec decisions at system level
- Remote access is handled via Tailscale — no VPN port exposed publicly
- Sensitive services are protected by NPM access lists
- Public exposure is verified regularly via an automated port scan triggered from GitHub Actions

---

## Roadmap

- [ ] NAS setup (pending hardware)
- [ ] Nextcloud deployment (pending hardware)
- [x] Grafana + Prometheus observability stack
- [x] Watchtower automatic updates
- [x] Multi-domain deployment script
- [x] Automated security port scan (GitHub Actions)
- [ ] Automated backups (Restic)
- [ ] CD pipeline — automatic deployment on push

---

## Technical decisions

### Why Docker?

All services run in containers rather than being installed directly on the host system for four reasons:

- **Isolation** — each service runs in its own environment. A crash or compromise in one container does not affect the others.
- **Portability** — the entire infrastructure is described in a `docker-compose.yaml` file. Rebuilding on a new machine is a single command.
- **Reproducibility** — the environment is frozen and versioned. No dependency drift, no "works on my machine" issues.
- **Simplified updates** — `docker compose pull && docker compose up -d` updates any service without touching the host system. Rolling back is as simple as pinning the previous image version.

---

### Why Tailscale over exposing SSH directly?

Exposing an SSH port on the internet means constant brute force attempts and exposure to zero-day vulnerabilities in the SSH daemon.

Tailscale creates an encrypted WireGuard tunnel between authorized devices. The SSH port is never exposed publicly — it simply does not exist from the internet's perspective. This reduces the attack surface to zero for remote access.

> A closed port cannot be attacked.

---

### Why CrowdSec over Fail2ban?

Fail2ban is reactive and local — it only learns from your own logs, after you have already been attacked.

CrowdSec brings two things Fail2ban cannot:

- **Community threat intelligence** — malicious IPs reported by thousands of servers worldwide are automatically blocked on your server, before they ever reach you.
- **Decoupled architecture** — the detection agent and the bouncer are separate components. The agent detects threats regardless of how they will be blocked. Adding a new bouncer (iptables, Nginx, Cloudflare) requires no changes to the detection layer. This separation of concerns mirrors patterns used in production security infrastructure.

---

### Why Nginx Proxy Manager over raw Nginx?

Configuring Nginx manually for multiple subdomains with SSL means writing server blocks by hand, installing Certbot, managing certificate renewal, and repeating the process for every new service.

Nginx Proxy Manager handles SSL certificate generation and renewal (Let's Encrypt), HTTP to HTTPS redirection, and proxy host configuration through a UI — reducing operational overhead significantly.

That said, NPM abstracts too much for complex production environments. In an enterprise context, direct Nginx or Traefik configuration would give finer control over headers, routing rules and rate limiting. NPM is the right tool for this scale.

---

### Why Grafana + Prometheus over Uptime Kuma alone?

Uptime Kuma answers one question: is the service up or down?

Grafana + Prometheus answer a different set of questions: how much CPU is the service consuming, is memory usage trending upward over time, is disk space running out?

Prometheus scrapes metrics from Node Exporter every 15 seconds and stores them for 15 days. Grafana queries Prometheus and renders the data into dashboards. The two tools are decoupled — Prometheus collects regardless of whether Grafana is running, and Grafana can query multiple datasources beyond Prometheus.

This mirrors the observability stack used in most production cloud environments.

---

### Why Watchtower?

Keeping Docker images up to date manually means regularly checking each service for new releases, pulling new images, and recreating containers. This is error-prone and easy to forget.

Watchtower automates this entirely — it runs every night at 3:00 AM, checks all running containers for new image versions, updates them in place, and removes the old images automatically. Zero manual intervention required.

This ensures security patches and bug fixes are applied consistently without operational overhead.

---

### Why a deployment script over environment variables?

Docker Compose supports `.env` files for variable substitution, but this only works for `docker-compose.yaml` files. Configuration files for Homepage, Mealie and other services are plain YAML files that do not support environment variable interpolation natively.

A `deploy.sh` script using `sed` covers all file types uniformly — a single command replaces the domain across every configuration file regardless of format. This makes the infrastructure fully portable without adding complexity or tooling dependencies.

---

### Why a custom port scanner over nmap?

nmap is the industry standard for port scanning, but it requires installation and adds a dependency to the CI pipeline.

The custom scanner built with Python's `socket` and `concurrent.futures` modules has zero external dependencies — Python is already available on every GitHub Actions runner. Every line of code is visible in the repository, fully auditable, and easy to extend. It scans all 65535 ports in parallel using multithreading, making it fast enough for automated use in CI.
