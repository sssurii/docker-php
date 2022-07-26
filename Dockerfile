FROM php:8.1-apache

LABEL maintainer="sssurii"

# Update
RUN apt-get update

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Install dev libs, wget, git etc
RUN apt-get install libpng-dev libicu-dev libpq-dev libzip-dev zip wget git -y

#Install php extensions
RUN docker-php-ext-install pdo_mysql zip gd exif sockets bcmath

#Install PostgreSQL extensions
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && docker-php-ext-install pdo_pgsql pgsql

RUN docker-php-ext-configure intl \
    && docker-php-ext-install intl

RUN pecl install redis \
	&& pecl install xdebug \
	&& docker-php-ext-enable redis xdebug

RUN apt-get update && \
    apt-get install -y libxml2-dev && \
    docker-php-ext-install soap

#Enable re-write module
RUN a2enmod rewrite

# Set Apache webroot to "public" folder (for Laravel)
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf