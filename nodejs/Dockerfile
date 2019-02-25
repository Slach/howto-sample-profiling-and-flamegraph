FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl wget gnupg2 git
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt install -y nodejs=11.*
RUN apt-get install -y make g++ build-essential

ENV DB_HOST=mysql:3306
ENV DB_USER=nodejs
ENV DB_PASSWORD=nodejs
ENV DB_BLOG=nodejs
RUN git clone https://github.com/anteknik/express-blog.git /opt/express-blog
WORKDIR /opt/express-blog/
RUN npm install -g gulp node-gyp
RUN npm install
CMD gulp server
