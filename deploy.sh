#!/bin/bash
set -e

echo "=== Deployment started ==="

# Pull latest code
echo "Pulling latest code..."
git pull origin Advanced

# Build new images
echo "Building Docker images..."
docker compose build --no-cache

# Stop current containers (micro-coupure)
echo "Stopping current containers..."
docker compose down

# Start new containers
echo "Starting new containers..."
docker compose up -d

# Wait for health checks
echo "Waiting for services to be healthy..."
sleep 10

# Verify containers are running
docker compose ps

echo "=== Deployment completed successfully ==="
