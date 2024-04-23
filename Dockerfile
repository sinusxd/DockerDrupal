# Используем официальный образ PHP с Apache
FROM php:7.4-apache

# Установка необходимых PHP-расширений и других пакетов
RUN apt-get update && apt-get install -y \
        libpng-dev \
        libjpeg-dev \
        libpq-dev \
        libzip-dev \
        unzip \
        git \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_pgsql zip

# Включаем mod_rewrite для Apache
RUN a2enmod rewrite

# Настройка Apache для правильного отображения index.php
RUN echo '<Directory "/var/www/html">' > /etc/apache2/conf-available/drupal.conf \
    && echo '  DirectoryIndex index.php index.html' >> /etc/apache2/conf-available/drupal.conf \
    && echo '</Directory>' >> /etc/apache2/conf-available/drupal.conf \
    && a2enconf drupal.conf

# Установка Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Установка Drupal с помощью Composer
WORKDIR /var/www/html
RUN composer create-project drupal/recommended-project .

# Копирование и установка прав на файлы и директории
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Открываем 80 порт
EXPOSE 80

# Запускаем Apache сервер в фоновом режиме
CMD ["apache2-foreground"]
