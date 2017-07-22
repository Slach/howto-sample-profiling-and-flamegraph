# Howto reproduce my results

* install latest docker and docker-compose and run following commands on empty ubuntu 16.04

## PHP
```bash
apt-get install -y apache2-utils
docker-compose up -d
NGINX_CONTAINER_ID=`docker ps | grep nginx | cut -d " " -f 1`
WORDPRESS_CONTAINER_ID=`docker ps | grep wordpress | cut -d " " -f 1`
NGINX_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER_ID`
echo $NGINX_CONTAINER_ADDR demo.wordpress.local >> /etc/hosts
# run ab in background, for imitate workload
ab -n 1000 -c 50 http://demo.wordpress.local/wp-admin/setup-config.php 2>&1 > /tmp/ab_results.log &

#build flamegraph SVG from xhprof sampling data
docker-compose exec wordpress sh -c "php -f /opt/xhprof-flamegraphs/xhprof-sample-to-flamegraph-stacks /tmp/xhprof | /opt/FlameGraph/flamegraph.pl > /tmp/xhprof-flamegraph.svg"

# grab from container to HOST and open received file in browser
docker cp $WORDPRESS_CONTAINER_ID:/tmp/xhprof-flamegraph.svg /tmp/xhprof-flamegraph.svg 

```

## GOLANG

```bash
docker-compose up -d
JUNO_TEST_CONTAINER_ID=`docker ps | grep juno | cut -d " " -f 1`
JUNO_TEST_CONTAINER_ADDR=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $JUNO_TEST_CONTAINER_ID`
apt-get install -y redis-tools
# run redis-benchmark in background, for imitate workload
redis-benchmark -h $JUNO_TEST_CONTAINER_ADDR -p 8379 -n 10000000 -c 100 -t set,get 2>&1 > /tmp/redis_results.log &
docker-compose run go-torch

# grab from container to HOST and open received file in browser
firefox /tmp/go-torch-flamegraph.svg 

```
