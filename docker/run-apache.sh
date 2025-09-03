#!/usr/bin/env sh
set -e

PORT="${PORT:-8080}"

# Ganti Listen port di Apache sesuai $PORT runtime
sed -ri "s/^[# ]*Listen[[:space:]]+[0-9]+/Listen ${PORT}/" /etc/apache2/ports.conf

# Ganti VirtualHost port di vhost default
sed -ri "s@<VirtualHost \*:[0-9]+>@<VirtualHost *:${PORT}>@" /etc/apache2/sites-available/000-default.conf

echo "Apache will listen on port ${PORT}"
exec apache2-foreground
