﻿FROM ubuntu:18.04
ENV DEBIANFRONTEND=noninteractive
RUN rgrep -l archive.ubuntu.com /etc/apt/ | xargs -P0 -I{} sed -i -e 's/archive.ubuntu.com/ru.archive.ubuntu.com/' {}
RUN apt-get update && apt-get install -y software-properties-common python3-pip git procps

RUN apt-add-repository -y ppa:trevorjay/pyflame && apt-get update && apt-get install -y pyflame
RUN git clone https://github.com/brendangregg/FlameGraph.git /opt/FlameGraph

RUN pip3 install -U py-spy

RUN pip3 install -U gunicorn Flask-Blogging
EXPOSE 5000
WORKDIR /
COPY ./python/flask_blog_gunicorn.py /
CMD gunicorn -w 4 --bind 0.0.0.0:5000 flask_blog_gunicorn:app