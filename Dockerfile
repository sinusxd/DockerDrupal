# Используем официальный образ PHP с Apache
FROM php:7.4-apache

# Установка необходимых PHP-расширений и других пакетов
RUN apt-get update && apt-get install -y \
        libpng-dev \
        libjpeg-dev \
        libpq-dev \
        libzip-dev \
        unzip \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_pgsql zip

# Включаем mod_rewrite для Apache
RUN a2enmod rewrite

# Установка Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Установка Drupal с помощью Composer
WORKDIR /var/www/html
RUN composer create-project drupal/recommended-project .

# Установка прав на директории
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Открываем 80 порт
EXPOSE 80

# Запускаем Apache сервер в фоновом режиме
CMD ["apache2-foreground"]
