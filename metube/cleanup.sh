#!/bin/bash

DIR="/srv/docker/metube/downloads"
LIMIT=1000000  # 1 Go en KB (~1GB)

SIZE=$(du -s "$DIR" | awk '{print $1}')

if [ "$SIZE" -gt "$LIMIT" ]; then
  echo "Cleaning downloads folder..."
  rm -rf "$DIR"/*
fi
