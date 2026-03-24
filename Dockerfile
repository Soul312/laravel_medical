FROM php:8.2-apache

# Install required tools and PostgreSQL extensions for Laravel
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

# Enable Apache mod_rewrite for Laravel routing
RUN a2enmod rewrite

# Set the working directory in the server
WORKDIR /var/www/html

# Install Composer securely
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy your GitHub code into the server
COPY . /var/www/html

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts

# Set the correct permissions so Laravel can write to the cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Create empty cache files so optimize commands can run safely in production containers
RUN mkdir -p bootstrap/cache \
    && touch bootstrap/cache/packages.php bootstrap/cache/services.php

# Point Apache to Laravel's public/ folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80