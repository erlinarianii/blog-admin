# Base PHP dengan Apache
FROM php:8.2-apache

WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip pkg-config libicu-dev libzip-dev zlib1g-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev libonig-dev \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Install PHP extensions
RUN docker-php-ext-install intl zip pdo_mysql bcmath pcntl gd mbstring opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install Node dependencies dan build assets
RUN npm install && npm run build

# Publish Filament assets
RUN php artisan filament:assets --force || echo "DEBUG: filament assets gagal"

# Setelah composer install dan artisan migrate
RUN php artisan storage:link || true

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 storage bootstrap/cache

# ---------------------------
# Apache config untuk Laravel
# ---------------------------
RUN echo '<VirtualHost *:${PORT}>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    Header always set X-Forwarded-Proto "https"\n\
    Header always set X-Forwarded-Port "443"\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Gunakan PORT dari Railway
ENV PORT=8080
RUN sed -i "s/Listen 80/Listen ${PORT}/g" /etc/apache2/ports.conf \
    && sed -i "s/:80/:${PORT}/g" /etc/apache2/sites-available/000-default.conf

EXPOSE ${PORT}

# Copy dan set permissions untuk script
COPY wait-for-db.sh /usr/local/bin/wait-for-db.sh
RUN chmod +x /usr/local/bin/wait-for-db.sh

# Entry point
CMD ["/usr/local/bin/wait-for-db.sh"]