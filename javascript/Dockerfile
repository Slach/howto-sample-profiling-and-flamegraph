FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl wget gnupg2 git
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt install -y nodejs=11.*
RUN nodejs --version
RUN apt-get install -y python3-pip
RUN pip3 install -U PyPOM
RUN apt-get install -y libasound2 libnspr4 libnss3 libxss1 xdg-utils unzip libappindicator1 libappindicator3-1 fonts-liberation
RUN curl -sL -o /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i /tmp/google-chrome-stable_current_amd64.deb

# Chrome 73.x
# ENV CHROMEDRIVER_VERSION=73.0.3683.20
# Crhome 72.x
ENV CHROMEDRIVER_VERSION=2.46
RUN curl -sL -o /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip
RUN unzip -d /tmp/ /tmp/chromedriver_linux64.zip
RUN mv -fv /tmp/chromedriver /usr/bin/chromedriver
RUN chown root:root /usr/bin/chromedriver && chmod +x /usr/bin/chromedriver

RUN npm install -g chrome-remote-interface chrome-launcher
RUN npm install -g cpuprofile2stackcollapse

RUN git clone https://github.com/brendangregg/FlameGraph.git /opt/FlameGraph
RUN git clone https://github.com/jamesseanwright/automated-chrome-profiling.git /opt/automated-chrome-profiling

RUN curl -sL https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz | tar -xz -C /bin/

RUN cd /opt/automated-chrome-profiling && npm install
WORKDIR /opt/automated-chrome-profiling

CMD /bin/dockerize -timeout 60s -wait tcp://nginx:80 -wait tcp://bitrix:9000 nodejs bitrix-setup-cpu-profile.js