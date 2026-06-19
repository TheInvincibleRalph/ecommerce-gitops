FROM php:8.2-apache

WORKDIR /var/www/html

# Install MySQL client to connect to the database from the application container & enable Apache rewrite module to handle URL rewriting
RUN apt-get update && apt-get install -y \
    libmemcached-dev zlib1g-dev librabbitmq-dev \
    && pecl install memcached amqp \
    && docker-php-ext-enable memcached amqp \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && a2enmod rewrite

COPY app/ecommerce-app .

RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Make DB env vars available to PHP
RUN echo 'PassEnv DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD' > /etc/apache2/conf-available/ecommerce-env.conf \
    && a2enconf ecommerce-env

EXPOSE 80

CMD ["apache2-foreground"]
