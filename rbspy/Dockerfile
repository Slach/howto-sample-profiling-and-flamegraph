FROM ubuntu:18.04
ENV DEBIANFRONTEND=noninteractive
RUN rgrep -l archive.ubuntu.com /etc/apt/ | xargs -P0 -I{} sed -i -e 's/archive.ubuntu.com/ru.archive.ubuntu.com/' {}
RUN apt-get update
RUN apt-get install -y locales tzdata iproute2
ENV LANG=en_US.UTF-8
RUN locale-gen --purge "en_US.UTF-8"
RUN dpkg-reconfigure -f noninteractive locales
RUN dpkg-reconfigure -f noninteractive tzdata
RUN update-locale LANG=en_US.UTF-8
RUN apt-get install -y bash wget ruby ruby-dev libxml2-dev libxslt-dev libcurl4-openssl-dev nodejs libsqlite3-dev git imagemagick libpq-dev libmysqlclient-dev
RUN mkdir -p /opt/puglify/
WORKDIR /opt/puglify/
RUN git clone https://github.com/publify/publify.git /opt/puglify/
RUN cp -fv config/database.yml.sqlite config/database.yml
RUN gem install bundler
RUN bundle install
RUN rake db:setup
RUN rake db:migrate
RUN rake db:seed
RUN rake assets:precompile
RUN wget -q -O- https://github.com/rbspy/rbspy/releases/download/v0.3.5/rbspy-v0.3.5-x86_64-unknown-linux-musl.tar.gz | tar -C /bin/ -zxv
CMD rails server