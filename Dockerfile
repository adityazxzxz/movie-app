# =========================
# Stage 0 — Frontend build (Vite)
# =========================
FROM node:20-alpine AS frontend

WORKDIR /app

# Copy frontend config
COPY package.json package-lock.json vite.config.* ./
RUN npm ci

# Copy resources only
COPY resources ./resources

# Build Vite assets
RUN npm run build


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

# Copy Vite build result
COPY --from=frontend /app/public/build /app/public/build

# Install runtime PHP extensions
RUN install-php-extensions \
    gd zip pdo_mysql sockets pcntl posix opcache intl

# Expose HTTP port
EXPOSE 80

# Run FrankenPHP
CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]
