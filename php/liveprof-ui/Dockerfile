FROM php:7.3
MAINTAINER Eugene Klimov <bloodjazman@gmail.com>

RUN apt-get update && apt-get -y install git-core unzip mysql-client \
&& pecl install xdebug-beta \
&& echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini
RUN curl -sL --show-error https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# mysql extension
RUN docker-php-ext-install -j$(nproc) mysqli pdo_mysql

RUN curl -sL https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz | tar -xz -C /bin/
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.8/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=be43e64c45acd6ec4fce5831e03759c89676a0ea

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

WORKDIR /app
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV LIVEPROF_MYSQL_PORT=3306
# TODO wait when merge https://github.com/badoo/liveprof-ui/pull/6
RUN git clone https://github.com/Slach/liveprof-ui.git /app/
RUN composer install
COPY ./php/liveprof-ui/crontab /etc/cron.d/liveprof-ui-cron
RUN chmod 0600 /etc/cron.d/liveprof-ui-cron
CMD /bin/dockerize -timeout 60s -wait tcp://mysql:3306 php bin/cli.php aggregator:install && mysql --user=${LIVEPROF_MYSQL_USER} --password=${LIVEPROF_MYSQL_PASS} -h ${LIVEPROF_MYSQL_HOST} -P ${LIVEPROF_MYSQL_PORT} -e "ALTER TABLE aggregator_metods CHANGE name name VARCHAR(1024)" ${LIVEPROF_MYSQL_DB} && php -S 0.0.0.0:8000 -t src/www/ src/www/router.php