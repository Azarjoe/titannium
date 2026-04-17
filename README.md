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
* **OS:** Ubuntu 24.04.4 LTS
* **Kernel:** Linux 6.8
* **Architecture:** x86_64
* **Storage:** 232GB (LVM)

---

## 🐳 Docker Stack

All services are orchestrated using a single `docker-compose.yaml`.

### 🔧 Core Services

| Service                | Description             | URL                            |
| ---------------------- | ----------------------- | ------------------------------ |
| 🏠 Homepage            | Dashboard / central hub | https://home.titannium.fr      |
| 🌐 Nginx Proxy Manager | Reverse proxy + SSL     | https://npm.titannium.fr       |
| 📦 Portainer           | Docker management UI    | https://portainer.titannium.fr |

---

### 🔐 Security & Tools

| Service            | Description                    | URL                            |
| ------------------ | ------------------------------ | ------------------------------ |
| 🔑 Password Pusher | Secure one-time secret sharing | https://secret.titannium.fr    |
| 🎵 MeTube          | YouTube → MP3/MP4 downloader   | https://ytconvert.titannium.fr |

---

### 👨‍👩‍👧‍👦 Family Services

| Service      | Description                   | URL                           |
| ------------ | ----------------------------- | ----------------------------- |
| 🍝 Mealie    | Recipe manager & meal planner | https://recettes.titannium.fr |
| 📁 NAS (WIP) | Future storage system         | https://nas.titannium.fr      |

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
├── homepage/
├── npm/
├── portainer/
├── pwpush/
├── mealie/
├── metube/
├── maintenance/
```

---

## 🌍 Networking

* Reverse proxy handled by **Nginx Proxy Manager**
* Custom domains via OVH
* Automatic SSL (Let's Encrypt) 🔐

---

## 🔒 Security

* HTTPS enforced on all public services
* Sensitive data not tracked in Git
* One-time secret sharing via Password Pusher

---

## ⚠️ Git Strategy

This repository contains **configuration only**.

❌ Not versioned:

* Databases (`*.db`)
* Downloads (`/metube/downloads`)
* Docker volumes
* Certificates

✔ Versioned:

* `docker-compose.yaml`
* Homepage config
* Scripts

---

## 🚧 Roadmap

### 🔜 Next Steps

* 💾 NAS setup (RAID + storage)
* ☁️ Nextcloud deployment
* 📸 Photo backup system (Immich)
* 📊 Monitoring & alerting

---

## 🎯 Purpose

This project is built to:

> Learn, experiment and provide real value to close relatives through self-hosted services.

---

## 😎 Author

**Julien Sage**
Homelab enthusiast • Dev • Cloud & Infra learner

---

## ⭐ Final Note

This homelab is a work in progress and will evolve into a fully featured private cloud infrastructure.
