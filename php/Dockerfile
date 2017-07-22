FROM wordpress:php7.1-fpm
RUN apt-get update && apt-get install -y git && cd /opt && \
    git clone https://github.com/msonnabaum/xhprof-flamegraphs.git && \
    git clone https://github.com/brendangregg/FlameGraph.git
RUN mkdir -p -m 0777 /tmp/xhprof && chown www-data:www-data /tmp/xhprof && git clone https://github.com/longxinH/xhprof && \
    cd xhprof/extension && \
    phpize  && \
    ./configure --with-php-config=/usr/local/bin/php-config  && \
    make && make install
