#!/bin/bash
set -e

echo "Waiting for MySQL to be ready..."
until php -r "new PDO('mysql:host=${DB_HOST};port=${DB_PORT}', '${DB_USERNAME}', '${DB_PASSWORD}');" 2>/dev/null; do
  echo "MySQL not ready yet, retrying in 2s..."
  sleep 2
done
echo "MySQL is ready."

if [ ! -f .env ]; then
  echo "Creating .env file..."
  cp .env.example .env
fi

echo "Generating APP_KEY..."
php artisan key:generate --force

echo "Running migrations..."
php artisan migrate --force

echo "Seeding database..."
php artisan db:seed --force || echo "Seeding skipped (Faker not available in production)"

echo "Starting PHP-FPM..."
exec php-fpm
