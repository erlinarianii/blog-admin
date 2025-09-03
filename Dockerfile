# Base PHP + Apache (PHP 8.3)
FROM php:8.3-apache

WORKDIR /var/www/html

# System deps + Node 20
RUN apt-get update && apt-get install -y \
    git curl unzip pkg-config libicu-dev libzip-dev zlib1g-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev libonig-dev \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache modules
RUN a2enmod rewrite headers

# PHP extensions
RUN docker-php-ext-install intl zip pdo_mysql bcmath pcntl gd mbstring opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy source code
COPY . .

# Install PHP deps
RUN composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader

# Build assets
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi \
 && npm run build

# Optional Artisan steps (don’t fail the build if unavailable)
RUN php artisan filament:assets --force || echo "DEBUG: filament assets failed (ignore)" \
 && php artisan storage:link || true

# Permissions
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 storage bootstrap/cache

# Write a default vhost on port 80 (we switch to $PORT at runtime)
RUN printf '%s\n' \
  '<VirtualHost *:80>' \
  '    DocumentRoot /var/www/html/public' \
  '    <Directory /var/www/html/public>' \
  '        AllowOverride All' \
  '        Require all granted' \
  '    </Directory>' \
  '    Header always set X-Forwarded-Proto "https"' \
  '    Header always set X-Forwarded-Port "443"' \
  '</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Copy runtime entrypoint to set $PORT dynamically
COPY --chmod=0755 docker/run-apache.sh /usr/local/bin/run-apache

# EXPOSE is informational; keep a common default
EXPOSE 8080

# Start Apache via our runtime script (binds to $PORT)
CMD ["run-apache"]
