# Howto reproduce my results

* install latest docker and docker-compose and run following commands on empty ubuntu 16.04

## PHP
```bash
apt-get install -y apache2-utils
docker-compose up -d
NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
WORDPRESS_CONTAINER_ID=`docker ps | grep wordpress | cut -d " " -f 1`
echo $NGINX_CONTAINER_ADDR demo.wordpress.local >> /etc/hosts
# run ab in background, for imitate workload
ab -n 1000 -c 50 http://demo.wordpress.local/wp-admin/setup-config.php 2>&1 > /tmp/ab_results_php.log &

#build flamegraph SVG from xhprof sampling data
docker-compose exec wordpress sh -c "php -f /opt/xhprof-flamegraphs/xhprof-sample-to-flamegraph-stacks /tmp/xhprof | /opt/FlameGraph/flamegraph.pl > /tmp/xhprof-flamegraph.svg"

ls -la /tmp/*.svg
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