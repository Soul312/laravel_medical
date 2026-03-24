FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN a2enmod rewrite


WORKDIR /var/www/html


COPY --from=composer:2 /usr/bin/composer /usr/bin/composer


COPY . /var/www/html

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts

# Set the correct permissions so Laravel can write to the cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Ensure stale manifest cache files are removed; Laravel will regenerate valid manifests
RUN mkdir -p bootstrap/cache \
    && rm -f bootstrap/cache/packages.php bootstrap/cache/services.php

# Point Apache to Laravel's public/ folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80