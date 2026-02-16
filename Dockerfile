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
RUN curl -sS https://getcomposer.org/installer | php \
    -- --install-dir=/usr/local/bin --filename=composer

# Copy backend files
COPY . .

# Install PHP dependencies (NO dev)
RUN composer install --no-dev --optimize-autoloader --no-interaction


# =========================
# Stage 2 — FrankenPHP runtime
# =========================
FROM dunglas/frankenphp:php8.4

WORKDIR /app

# Copy backend app + vendor
COPY --from=vendor /app /app

# ❗ public/build sudah dari lokal → tidak perlu COPY frontend stage

# Install runtime PHP extensions
RUN install-php-extensions \
    gd zip pdo_mysql sockets pcntl posix opcache intl

EXPOSE 80

CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]
