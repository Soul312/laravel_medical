#!/usr/bin/env sh
set -eu

cd /var/www/html

# Ensure caches are clean and package manifests are valid before serving traffic.
php artisan optimize:clear
php artisan package:discover --ansi

# Run pending migrations on startup, retrying while the database comes up.
attempt=1
max_attempts=10
until php artisan migrate --force; do
	if [ "$attempt" -ge "$max_attempts" ]; then
		echo "Migration failed after ${max_attempts} attempts. Exiting."
		exit 1
	fi

	echo "Migration attempt ${attempt} failed. Retrying in 5 seconds..."
	attempt=$((attempt + 1))
	sleep 5
done

exec apache2-foreground
