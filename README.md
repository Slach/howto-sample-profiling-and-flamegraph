# Howto reproduce my results

## Common steps
* install latest docker and docker-compose and run following commands on ubuntu 18.04
```bash
apt-get update
apt-get install -y apt-transport-https software-properties-common apache2-utils git

# docker
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D81803C0EBFCD88
add-apt-repository "deb https://download.docker.com/linux/ubuntu bionic edge"

apt-get update
apt-get install -y docker-ce python-pip apache2-utils
pip install -U docker-compose requests

# install additional external dependencies
git clone https://github.com/Netflix/flamescope.git /opt/flamescope/
git clone https://github.com/badoo/liveprof-ui.git /opt/liveprof-ui/
```

## PHP - wordpress - XHProf
```bash
docker-compose run wordpress-install 
docker-compose up -d nginx 
NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.wordpress.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.wordpress.local >> /etc/hosts
# run ab in background, for imitate workload
ab -n 10000 -c 50 http://demo.wordpress.local/index.php 2>&1 > /tmp/ab_results_php_xhprof.log &

#build flamegraph SVG from xhprof sampling data
docker-compose exec wordpress sh -c "php -f /opt/xhprof-flamegraphs/xhprof-sample-to-flamegraph-stacks /tmp | /opt/FlameGraph/flamegraph.pl > /tmp/xhprof-flamegraph.svg"
ls -la /tmp/*.svg
```

## PHP - wordpress - phpspy
```bash
docker-compose run wordpress-install 
docker-compose up -d nginx
NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.wordpress.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.wordpress.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 1000 -c 50 http://demo.wordpress.local/index.php 2>&1 > /tmp/ab_results_php_phpspy.log &

# collect sampling data for phpspy and build flamegraph via pipe
# TODO wait when https://github.com/adsr/phpspy/issues/56 will fix for improve accurancy
# TODO wait when fixed infinite loop https://github.com/adsr/phpspy/issues/42#issuecomment-467153833
docker-compose exec wordpress sh -c "/opt/phpspy/phpspy -P php-fpm -T 32 -V73 -l 1000 | /opt/phpspy/stackcollapse-phpspy.pl | /opt/phpspy/vendor/flamegraph.pl > /tmp/phpspy-flamegraph.svg"

ls -la /tmp/*.svg
```

## PHP - wordpress - liveprof
```bash
docker-compose run wordpress-install 
docker-compose up -d mysql nginx liveprof-cron
NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.wordpress-liveprof.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.wordpress-liveprof.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 1000 -c 50 http://demo.wordpress-liveprof.local/index.php 2>&1 > /tmp/ab_results_php_liveprof.log &

# open http://demo.liveprof-ui.local/ in your browser
```
## PYTHON
```bash
apt
```

## GOLANG
```bash
docker-compose up -d
JUNO_TEST_CONTAINER_ID=`docker ps | grep juno | cut -d " " -f 1`
JUNO_TEST_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $JUNO_TEST_CONTAINER_ID`
apt-get install -y redis-tools
# run redis-benchmark in background, for imitate workload
redis-benchmark -h $JUNO_TEST_CONTAINER_ADDR -p 8379 -n 10000000 -c 100 -t set,get &> /tmp/redis_results.log &
docker-compose run go-torch

ls -la /tmp/*.svg
```

## RUBY

```bash
docker-compose up -d 

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`

echo $NGINX_CONTAINER_ADDR demo.publify.local >> /etc/hosts
# run ab in background, for imitate workload
ab -n 100000 -c 50 http://demo.publify.local/setup &> /tmp/ab_results_rbspy.log &

RBSPY_CONTAINER_ID=`docker ps -a | grep rbspy | cut -d " " -f 1`
RBSPY_PID=$(docker-compose exec rbspy sh -c "ss -nltp | grep ':3000' | sort | head -n 1 | cut -d '=' -f 2 | cut -d "," -f 1 | tr -d '\n' | tr -d '\r'")
docker-compose exec rbspy sh -c "rbspy record --pid=${RBSPY_PID} --raw-file=/tmp/rbspy-raw.gz --duration=60 --format=flamegraph --file=/tmp/rbspy-flamegraph"


ls -la /tmp/*.svg

```
## .Net Core (TODO)
- https://github.com/blogifierdotnet/Blogifier
- http://blogs.microsoft.co.il/sasha/2017/02/27/profiling-a-net-core-application-on-linux/
- http://dotsandbrackets.com/net-core-memory-linux-ru/

## NodeJS (TODO)
- https://github.com/hzhu/node-perf
- https://github.com/uber-node/node-flame

## Browser (Chromium) Javascript + PHPSpy
- https://github.com/jamesseanwright/automated-chrome-profiling

## Java (TODO)

https://github.com/jvm-profiling-tools/async-profiler

## Java Perf + FLAMESCOPE

```bash
docker-compose up -d

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
echo $NGINX_CONTAINER_ADDR demo.hlebushek.local >> /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.flamescope.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 200000 -c 50 http://demo.hlebushek.local/ &> /tmp/ab_results_java.log &

DT=$(date +'%Y-%m-%d_%H%M')
JAVA_PID=`docker-compose exec java ps -ef | grep java | tr -s ' ' | cut -d ' ' -f 2`
docker-compose exec java bash -c "rm -rfv /tmp/perf-$JAVA_PID.map && PERF_RECORD_SECONDS=15 /opt/perf-map-agent/bin/perf-java-record-stack $JAVA_PID -a && ls -la /tmp/" 
docker-compose exec java bash -c "perf script --header -i /tmp/perf-$JAVA_PID.data > /tmp/stacks.myproductionapp.$DT"

# open http://demo.flamescope.local in browser

```