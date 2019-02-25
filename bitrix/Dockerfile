FROM php:7.3-fpm

RUN apt-get update && apt-get install -y git perl unzip procps && cd /opt && \
    git clone https://github.com/msonnabaum/xhprof-flamegraphs.git && \
    git clone https://github.com/brendangregg/FlameGraph.git

RUN git clone https://github.com/longxinH/xhprof /opt/xhprof && \
    cd /opt/xhprof/extension && \
    phpize  && \
    ./configure --with-php-config=/usr/local/bin/php-config  && \
    make && make install

RUN apt-get install -y python-pip
RUN git clone https://github.com/adsr/phpspy.git /opt/phpspy && \
    cd /opt/phpspy && \
    make

WORKDIR /var/www/bitrix
RUN curl -sL http://www.1c-bitrix.ru/download/files/start_encode.tar.gz | tar -xz -C /var/www/bitrix

ENV LIVE_PROFILER_CONNECTION_URL="mysql://liveprof:liveprof@mysql:3306/liveprof?charset=utf8"
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sL --show-error https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
RUN mkdir -p /opt/liveprof && cd /opt/liveprof && composer require --verbose -o badoo/liveprof

RUN curl -sL https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz | tar -xz -C /bin/
RUN docker-php-ext-install pdo_mysql

CMD /bin/dockerize -timeout 60s -wait tcp://mysql:3306 php /opt/liveprof/vendor/badoo/liveprof/bin/install.php && /usr/local/bin/docker-php-entrypoint php-fpm
