FROM ubuntu:18.04
ENV DEBIANFRONTEND=noninteractive
RUN rgrep -l archive.ubuntu.com /etc/apt/ | xargs -P0 -I{} sed -i -e 's/archive.ubuntu.com/by.archive.ubuntu.com/' {}
RUN apt-get update && apt-get install -y curl wget gnupg2 git linux-tools-`uname -r`  systemtap cmake sudo nginx
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt install -y nodejs=11.*
RUN apt-get install -y make g++ build-essential
RUN npm install -g gulp node-gyp

RUN git clone https://github.com/uber/node-stap /opt/node-stap
# RUN cd /opt/node-stap && npm install -g
RUN git clone https://github.com/uber-node/node-flame.git /opt/node-flame
# TODO wait resolve https://github.com/uber-node/node-flame/issues/3
# RUN cd /opt/node-flame && npm build && npm install -g

ENV DB_HOST=mysql:3306
ENV DB_USER=nodejs
ENV DB_PASSWORD=nodejs
ENV DB_BLOG=nodejs
RUN git clone https://github.com/brendangregg/FlameGraph.git /opt/FlameGraph
RUN git clone https://github.com/Slach/express-blog.git /opt/express-blog
WORKDIR /opt/express-blog/
RUN npm install jade
RUN npm install
CMD gulp server
