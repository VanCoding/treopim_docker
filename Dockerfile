FROM php:7.2-apache

EXPOSE 80

RUN apt-get update && apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libldap2-dev \
        zip \
        unzip \
        git \
        cron \
        && rm -rf /var/lib/apt/lists/*
RUN a2enmod rewrite

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install exif
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd
RUN docker-php-ext-install ldap
RUN docker-php-ext-install zip
RUN pecl install mailparse && docker-php-ext-enable mailparse

RUN sed -i 's/max_execution_time = .*/max_execution_time = '180'/' /usr/local/etc/php/php.ini-development
RUN sed -i 's/max_input_time = .*/max_input_time = '180'/' /usr/local/etc/php/php.ini-development
RUN sed -i 's/memory_limit = .*/memory_limit = '256M'/' /usr/local/etc/php/php.ini-development
RUN sed -i 's/post_max_size = .*/post_max_size = '25M'/' /usr/local/etc/php/php.ini-development
RUN sed -i 's/upload_max_filesize = .*/upload_max_filesize = '25M'/' /usr/local/etc/php/php.ini-development
RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

COPY ./composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
WORKDIR /var/www/html/

RUN composer create-project treolabs/skeleton ./ --no-dev
RUN chown -R www-data:www-data ./
RUN chmod +x ./bin/*.sh
RUN printf '* * * * * cd /var/www; ./bin/cron.sh process-treocore /usr/local/bin/php\n' | crontab -u www-data -
COPY ./entrypoint.sh /
ENTRYPOINT /entrypoint.sh
