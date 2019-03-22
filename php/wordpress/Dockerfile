FROM wordpress:php7.3-fpm

# TODO wait merge https://github.com/msonnabaum/xhprof-flamegraphs/pull/5
RUN apt-get update && apt-get install -y git perl sudo less procps mysql-client && \
    cd /opt && \
    git clone https://github.com/Slach/xhprof-flamegraphs.git && \
    git clone https://github.com/brendangregg/FlameGraph.git


RUN git clone https://github.com/longxinH/xhprof /opt/xhprof && \
    cd /opt/xhprof/extension && \
    phpize  && \
    ./configure --with-php-config=/usr/local/bin/php-config  && \
    make && make install

RUN apt-get install -y python-pip
RUN git clone https://github.com/adsr/phpspy.git /opt/phpspy
RUN cd /opt/phpspy && make

RUN docker-php-ext-install pdo_mysql

RUN curl -sL https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz | tar -xz -C /bin/

ENV LIVE_PROFILER_CONNECTION_URL="mysql://liveprof:liveprof@mysql:3306/liveprof?charset=utf8"
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sL --show-error https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
# https://github.com/badoo/liveprof/pull/2 merged ;)
RUN git clone https://github.com/badoo/liveprof.git /opt/liveprof && cd /opt/liveprof && composer install --verbose

# Add WP-CLI
RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY ./php/wordpress/wp.sh /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp

CMD /bin/dockerize -timeout 60s -wait tcp://mysql:3306 php /opt/liveprof/bin/install.php && /usr/local/bin/docker-entrypoint.sh php-fpm
