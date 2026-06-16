FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libgd-dev libzip-dev libpng-dev libjpeg-dev \
    libonig-dev libxml2-dev curl unzip git \
    && docker-php-ext-install pdo_mysql mbstring xml ctype bcmath zip gd \
    && a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer config --global allow-plugins.pestphp/pest-plugin true
RUN composer config --global secure-http false
ENV COMPOSER_NO_AUDIT=1
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-scripts --no-interaction --ignore-platform-reqs

RUN cp .env.example .env && php artisan key:generate

RUN chown -R www-data:www-data storage bootstrap/cache

ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80
