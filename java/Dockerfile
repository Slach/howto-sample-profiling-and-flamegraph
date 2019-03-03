# TODO wait when https://github.com/jvm-profiling-tools/perf-map-agent/pull/71 will merged
FROM openjdk:8-stretch
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git maven linux-perf cmake make g++ sudo openjdk-8-dbg
RUN mkdir -p /opt/perf-map-agent && git clone https://github.com/jvm-profiling-tools/perf-map-agent /opt/perf-map-agent
RUN cd /opt/perf-map-agent && cmake --version && cmake . && make
RUN mkdir -p /opt/async-profiler
RUN curl -s -L https://github.com/jvm-profiling-tools/async-profiler/releases/download/v1.5/async-profiler-1.5-linux-x64.tar.gz | tar -xvz -C /opt/async-profiler
RUN git clone https://github.com/autoschool/hlebushek.git /opt/hlebushek
RUN cd /opt/hlebushek && mvn compile