# =========================
# Stage 1 — Composer dependencies
# =========================
FROM php:8.4-cli AS vendor

WORKDIR /app

# System deps + PHP extensions
RUN apt-get update && apt-get install -y \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        zlib1g-dev \
        libicu-dev \
        git \
        unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd zip pdo_mysql sockets pcntl posix opcache intl

# Install Composer
RUN curl -sS https://getcomposer.org/download/2.6.5/composer.phar \
    -o /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

# Copy project
COPY . .

# Install dependencies (TANPA Octane)
RUN composer install --no-dev --optimize-autoloader --no-interaction
RUN npm run build

# =========================
# Stage 2 — FrankenPHP runtime
# =========================
FROM dunglas/frankenphp:php8.4

WORKDIR /app

# Copy app + vendor
COPY --from=vendor /app /app

# Install runtime extensions (kalau belum ada)
RUN install-php-extensions \
    gd zip pdo_mysql sockets pcntl posix opcache intl

RUN php artisan migrate    

# FrankenPHP default port
EXPOSE 80

# Jalankan FrankenPHP (serve Laravel public/)
CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]
