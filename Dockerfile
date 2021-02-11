FROM php:7.3-fpm-alpine

# Required and recommended libraries (2 layers)
# GD
RUN apk add --no-cache --update libpng-dev libjpeg-turbo-dev libzip-dev freetype-dev && \
   docker-php-ext-configure gd \
   --with-gd \
   --with-freetype-dir=/usr/include/ \
   --with-png-dir=/usr/include/ \
   --with-jpeg-dir=/usr/include/ && \
   NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
   docker-php-ext-install -j${NPROC} gd

# Others
RUN docker-php-ext-install mysqli zip exif

# Memcached
#ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev
#RUN apk add --no-cache libmemcached-libs zlib
#RUN set -xe \
#   && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
#   && apk add --no-cache --virtual .memcached-deps $MEMCACHED_DEPS \
#   && pecl install memcached \
#   && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
#   && rm -rf /usr/share/php7 \
#   && rm -rf /tmp/* \
#   && apk del .memcached-deps .phpize-deps

# Nginx
RUN adduser -D -g 'www' www
RUN apk add --no-cache nginx
COPY nginx.conf /etc/nginx/nginx.conf
#COPY info.php /var/www/index.php

# Confs
#RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY php.ini /usr/local/etc/php/php.ini
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /var/www

# Run the server
COPY entrypoint.sh /home
ENTRYPOINT ["sh", "/home/entrypoint.sh"]
