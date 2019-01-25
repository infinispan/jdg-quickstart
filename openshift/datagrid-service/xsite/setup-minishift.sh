#!/usr/bin/env bash

set -e -x

minishift profile set xsite-a
minishift config set memory 4GB
minishift config set cpus 2
minishift config set disk-size 25g
minishift config set image-caching true
minishift config set vm-driver xhyve # TODO add as parameter for script

minishift profile set xsite-b
minishift config set memory 4GB
minishift config set cpus 2
minishift config set disk-size 25g
minishift config set image-caching true
minishift config set vm-driver xhyve # TODO add as parameter for script
