FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    libgd-dev libzip-dev libpng-dev libjpeg-dev \
    libonig-dev libxml2-dev curl unzip git \
    && docker-php-ext-install pdo_mysql mbstring xml ctype bcmath zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_NO_AUDIT=1 composer install --no-dev --optimize-autoloader --no-scripts --no-interaction --ignore-platform-reqs

RUN cp .env.example .env && php artisan key:generate

RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
