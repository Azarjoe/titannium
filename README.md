# 🚀 Titannium Homelab

Personal self-hosted infrastructure built with Docker to provide useful, secure and family-friendly services.

---

## 🧠 Overview

**Titannium** is a personal homelab project designed to:

* Learn and master Docker & self-hosting 🐳  
* Provide useful services to family and relatives 👨‍👩‍👧‍👦  
* Replace third-party tools with self-hosted alternatives 🔐  
* Build a scalable foundation for a future NAS & private cloud ☁️  

---

## 🖥️ System Information

* **Hostname:** `nas`
* **OS:** Ubuntu 24.04 LTS
* **Architecture:** x86_64
* **Storage:** 232GB (LVM)

---

## 🐳 Docker Stack

All services are orchestrated using Docker Compose.

---

### 🔧 Core Services

| Service                | Description             | URL                            |
|----------------------|------------------------|--------------------------------|
| 🏠 Homepage           | Dashboard / central hub | https://home.titannium.fr      |
| 🌐 Nginx Proxy Manager| Reverse proxy + SSL     | https://npm.titannium.fr       |
| 📦 Portainer          | Docker management UI    | https://portainer.titannium.fr |

---

### 🔐 Security & Monitoring

| Service       | Description                          | URL                         |
|--------------|--------------------------------------|-----------------------------|
| 🛡️ CrowdSec   | IDS/IPS + automatic IP blocking      | https://app.crowdsec.net    |
| 📊 Uptime Kuma| Service monitoring & status          | https://kuma.titannium.fr   |
| 🔐 Tailscale  | Secure private network access        | Internal only               |

---

### 🛠️ Tools

| Service            | Description                    | URL                         |
|-------------------|--------------------------------|-----------------------------|
| 🔑 Password Pusher| Secure one-time secret sharing | https://secret.titannium.fr |
| 🎵 MeTube         | YouTube → MP3/MP4 downloader   | https://ytconvert.titannium.fr |

---

### 👨‍👩‍👧‍👦 Family Services

| Service      | Description                   | URL                           |
|--------------|-----------------------------|-------------------------------|
| 🍝 Mealie    | Recipe manager & meal planner| https://recettes.titannium.fr |
| 📁 NAS (WIP) | Future storage system        | https://nas.titannium.fr      |

---

### 🎬 External Shortcuts

Centralized access to commonly used platforms:

* Disney+
* Prime Video
* Max
* Ikromi

---

## 🏗️ Architecture

```bash
/srv/docker/
├── docker-compose.yaml
├── crowdsec/
│   ├── docker-compose.yml
│   └── config/
│       └── acquis.yaml
├── homepage/
├── npm/
├── portainer/
├── pwpush/
├── mealie/
├── metube/
├── uptime-kuma/
