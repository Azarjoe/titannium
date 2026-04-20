#!/bin/bash

# ============================================
# Titannium — Deployment Script
# ============================================

set -e

echo "=================================="
echo " Titannium Infrastructure Deployer"
echo "=================================="
echo ""

# Demande le domaine
read -p "Enter your domain (ex: mondomaine.fr): " DOMAIN

if [ -z "$DOMAIN" ]; then
  echo "Error: domain cannot be empty"
  exit 1
fi

echo ""
echo "-> Deploying with domain: $DOMAIN"
echo ""

# Remplace titannium.fr par le nouveau domaine dans tous les fichiers
FILES=(
  "docker-compose.yaml"
  "homepage/docker-compose.yml"
  "homepage/config/services.yaml"
  "homepage/config/settings.yaml"
  "mealie/docker-compose.yaml"
)

for FILE in "${FILES[@]}"; do
  if [ -f "$FILE" ]; then
    sed -i "s/titannium\.fr/$DOMAIN/g" "$FILE"
    echo "-> Updated $FILE"
  else
    echo "-> Skipped $FILE (not found)"
  fi
done

echo ""
echo "-> Starting services..."
docker compose up -d

echo ""
echo "=================================="
echo " Done ! Your infra is live on $DOMAIN"
echo "=================================="
