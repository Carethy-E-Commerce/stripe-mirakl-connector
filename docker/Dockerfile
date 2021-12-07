FROM php:7-apache AS web

#Install required php extensions
RUN apt-get update && apt-get install -y zip libpq-dev libgmp-dev
RUN docker-php-ext-install pgsql && docker-php-ext-install pdo_pgsql && docker-php-ext-install gmp


#Install composer
RUN php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/7c82360a69c44616cb7633521a27fea292708d70/web/download/2.1.3/composer.phar', 'composer.phar');" &&\
    mv composer.phar /usr/local/bin/composer &&\
    chmod +x /usr/local/bin/composer

#Apache configuration
RUN a2enmod rewrite

#Create var dir and make it writable
WORKDIR /var/www
RUN mkdir -p var && chmod -R go+w var

#Install composer dependencies
COPY composer.json /var/www
COPY composer.lock /var/www
WORKDIR /var/www/
RUN composer install --prefer-dist --no-scripts

#Copy project
COPY . /var/www/
WORKDIR /var/www/
RUN rm -df html && ln -s public html
RUN chown www-data:www-data .

#Copy public files specific for this image
COPY ./docker/public/.htaccess /var/www/public/.htaccess



FROM web AS cron

#Install supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=048b95b48b708983effb2e5c935a1ef8483d9e3e

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

#Test for crontab format to not build an invalid cron
RUN supercronic -test docker/cron/crontab

ENTRYPOINT supercronic docker/cron/crontab



FROM web AS workers
RUN apt-get --allow-releaseinfo-change update && apt-get install -y python python3 python-pip python3-pip
RUN pip install supervisor

ENTRYPOINT supervisord -c docker/workers/supervisord.conf
