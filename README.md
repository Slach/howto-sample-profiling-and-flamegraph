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

# set HOST kernel to available work perf inside container
echo -1 > /proc/sys/kernel/perf_event_paranoid
echo 0 > /proc/sys/kernel/kptr_restrict

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
docker-compose up -d wordpress
docker-compose run wordpress-install 
docker-compose up -d nginx
NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.wordpress.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.wordpress.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 1000 -c 50 http://demo.wordpress.local/index.php 2>&1 > /tmp/ab_results_php_phpspy.log &

# collect sampling data for phpspy and build flamegraph via pipe
# https://github.com/adsr/phpspy/issues/56 fixed for improve accurancy ;)
docker-compose exec wordpress sh -c "pgrep php-fpm | xargs -P0 -I{} bash -c '/opt/phpspy/phpspy -p {} -V73 --time-limit-ms 60000 | /opt/phpspy/stackcollapse-phpspy.pl | /opt/phpspy/vendor/flamegraph.pl > /tmp/phpspy-flamegraph.{}.svg'"

ls -la /tmp/phpspy*.svg
```

## PHP - wordpress - liveprof
```bash
docker-compose up -d mysql wordpress 
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

## PYTHON - pyflame
```bash
docker-compose up -d nginx python

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.python3.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.python3.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 20000 -c 50 http://demo.python3.local/ 2>&1 > /tmp/ab_results_php_pyflame.log & 
# run sampling
docker-compose exec python bash -c "pgrep gunicorn | xargs -P 0 -I{} bash -c 'pyflame -s 60 -p {} | /opt/FlameGraph/flamegraph.pl > /tmp/pyflame-flamegraph.{}.svg'"

ls -la /tmp/flamegraph-pyflame*.svg
```

## PYTHON - py-spy
```bash
docker-compose up -d nginx python

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.python3.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.python3.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 20000 -c 50 http://demo.python3.local/ 2>&1 > /tmp/ab_results_php_pyflame.log & 
# run sampling
docker-compose exec python bash -c "pgrep gunicorn | xargs -P 0 -I{} bash -c 'py-spy -d 60 -p {} --nonblocking --flame /tmp/pyspy-flamegraph.{}.svg'"

ls -la /tmp/flamegraph-pyflame*.svg
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
docker-compose up -d nginx 

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.publify.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.publify.local >> /etc/hosts
# run ab in background, for imitate workload
ab -n 100000 -c 50 http://demo.publify.local/setup &> /tmp/ab_results_rbspy.log &

# catch stracktraces via rbspy
RBSPY_CONTAINER_ID=`docker ps -a | grep rbspy | cut -d " " -f 1`
RBSPY_PID=$(docker-compose exec rbspy sh -c "ss -nltp | grep ':3000' | sort | head -n 1 | cut -d '=' -f 2 | cut -d "," -f 1 | tr -d '\n' | tr -d '\r'")
docker-compose exec rbspy sh -c "rbspy record --pid=${RBSPY_PID} --raw-file=/tmp/rbspy-raw.gz --duration=60 --format=flamegraph --file=/tmp/rbspy-flamegraph"


ls -la /tmp/*.svg

```

## .Net Core 
```bash
docker-compose up -d nginx 

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.blogifier.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.blogifier.local >> /etc/hosts
# run ab in background, for imitate workload
ab -n 10000 -c 50 http://demo.blogifier.local/ &> /tmp/ab_results_netcore.log &

# catch stack traces via perf

docker-compose exec netcore sh -c 'perf_4.9 record -F 99 -g -p `pgrep dotnet` -- sleep 60'
# output flamegraph
docker-compose exec netcore sh -c "perf_4.9 script | /opt/FlameGraph/stackcollapse-perf.pl | /opt/FlameGraph/flamegraph.pl > /tmp/netcore-flamegraph.svg"
```

## NodeJS 
```bash
docker-compose up -d nginx 

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.nodejs.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.nodejs.local >> /etc/hosts
# run ab in background, for imitate workload
ab -n 10000 -c 50 http://demo.nodejs.local/ &> /tmp/ab_results_netcore.log &

# collect flamegraph via node-stap
docker-compose exec nodejs sh -c 'nodejs /opt/node-stap/torch.js `pgrep node` flame 60 > /tmp/node-stap.html'
# collect flamegraph via node-flame not worked yet ;(
docker-compose exec nodejs sh -c 'node-flame `pgrep node` flame 60 > /tmp/node-flame.html'

# collect flamegraph via perf
perf record -F99 -g -p `pgrep node` -- sleep 60
docker-compose exec nodejs sh -c 'perf record -F99 -g -p `pgrep node` -- sleep 60'

perf script | /opt/FlameGraph/stackcollapse-perf.pl | /opt/FlameGraph/flamegraph.pl --colors js > /tmp/nodejs-flamegraph.svg
docker-compose exec nodejs sh -c 'perf script | /opt/FlameGraph/stackcollapse-perf.pl | /opt/FlameGraph/flamegraph.pl --colors js > /tmp/nodejs-flamegraph.svg'
```

## Java - Async Profiler
```bash
docker-compose up -d nginx java
NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.hlebushek.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.hlebushek.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 20000 -c 50 http://demo.hlebushek.local/ &> /tmp/ab_results_java.log &

docker-compose exec java sh -c "pgrep java | xargs -P0 -I{} /opt/async-profiler/profiler.sh collect -e itimer -i 10000000 -d 60 -f /tmp/java_flamegraph_async.{}.svg {}"
```


## Browser (Chromium) Javascript + PHPSpy
- https://github.com/jamesseanwright/automated-chrome-profiling


## Java - Perf + FLAMESCOPE

```bash
docker-compose up -d nginx java flamescope

NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
sed -i "/demo.hlebushek.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.hlebushek.local >> /etc/hosts
sed -i "/demo.flamescope.local/d" /etc/hosts
echo $NGINX_CONTAINER_ADDR demo.flamescope.local >> /etc/hosts

# run ab in background, for imitate workload
ab -n 200000 -c 50 http://demo.hlebushek.local/ &> /tmp/ab_results_java.log &

DT=$(date +'%Y-%m-%d_%H%M')
JAVA_PID=`docker-compose exec java pgrep java`
docker-compose exec java bash -c "rm -rfv /tmp/perf-$JAVA_PID.map && PERF_RECORD_SECONDS=60 /opt/perf-map-agent/bin/perf-java-record-stack $JAVA_PID -a && ls -la /tmp/" 
docker-compose exec java bash -c "perf script --header -i /tmp/perf-$JAVA_PID.data > /tmp/stacks.myproductionapp.$DT"

# open http://demo.flamescope.local in browser

```

## SQL - PostgreSQL (TODO)
- https://www.openscg.com/bigsql/docs/plprofiler/
- https://www.percona.com/blog/2019/02/13/plprofiler-getting-a-handy-tool-for-profiling-your-pl-pgsql-code/
