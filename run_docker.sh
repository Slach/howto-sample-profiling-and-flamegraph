#!/bin/bash
set -xeuo pipefail
echo 1 > /proc/sys/vm/drop_caches
docker-compose build
docker-compose up -d