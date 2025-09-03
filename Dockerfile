# Base PHP + Apache (PHP 8.3 sesuai requirement Filament/OpenSpout)
FROM php:8.3-apache

WORKDIR /var/www/html

# Sistem dependency + Node 20 (untuk Vite)
RUN apt-get update && apt-get install -y \
    git curl unzip pkg-config libicu-dev libzip-dev zlib1g-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev libonig-dev \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache modules
RUN a2enmod rewrite headers

# PHP extensions
# (Jika perlu GD opsi lengkap: docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp)
RUN docker-php-ext-install intl zip pdo_mysql bcmath pcntl gd mbstring opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy source code
COPY . .

# Composer install (tanpa dev) – non-interaktif & optimize
RUN composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader

# Build assets (pakai npm ci agar repeatable kalau ada package-lock.json)
# fallback ke npm install bila tidak ada lockfile
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi \
  && npm run build

# (Opsional) Publish Filament assets – tidak fatal bila gagal
RUN php artisan filament:assets --force || echo "DEBUG: filament assets failed (ignore)"

# (Opsional) Storage link – tidak fatal bila gagal saat build
RUN php artisan storage:link || true

# Permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 storage bootstrap/cache

# ---------------------------
# Apache vhost untuk Laravel
# ---------------------------
# Tulis vhost default pada port 80 dahulu, lalu ganti ke ${PORT} via sed
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

# Railway memberikan PORT via env, ganti listen dan vhost ke nilai PORT
ENV PORT=8080
RUN sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf && \
    sed -i "s/:80/:${PORT}/" /etc/apache2/sites-available/000-default.conf

# EXPOSE harus angka literal (bukan env var)
EXPOSE 8080

# Entry point Apache – tidak pakai wait-for-db lagi
CMD ["apache2-foreground"]
