FROM java
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git maven linux-perf linux-tools-4.4 cmake make g++ sudo
RUN mkdir -p /opt/perf-map-agent && git clone https://github.com/jvm-profiling-tools/perf-map-agent /opt/perf-map-agent
RUN cd /opt/perf-map-agent && cmake --version && cmake . && make
RUN git clone https://github.com/autoschool/hlebushek.git /opt/hlebushek
RUN cd /opt/hlebushek && mvn compile