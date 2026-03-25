#!/bin/bash
set -e

if [ "${DB_CONNECTION}" = "sqlite" ]; then
  echo "Preparing SQLite database..."
  mkdir -p "$(dirname "${DB_DATABASE}")"
  touch "${DB_DATABASE}"
else
  echo "Waiting for MySQL to be ready..."
  until php -r "new PDO('mysql:host=${DB_HOST};port=${DB_PORT}', '${DB_USERNAME}', '${DB_PASSWORD}');" 2>/dev/null; do
    echo "MySQL not ready yet, retrying in 2s..."
    sleep 2
  done
  echo "MySQL is ready."
fi

echo "Running migrations..."
php artisan migrate --force

echo "Seeding database..."
php artisan db:seed --force

echo "Starting Laravel server..."
exec php artisan serve --host=0.0.0.0 --port=8000
