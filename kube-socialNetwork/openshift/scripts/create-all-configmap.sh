#!/bin/bash

cd $(dirname $0)/..

./scripts/configmaps/create-jaeger-configmap.sh
./scripts/configmaps/create-media-frontend-configmap.sh
./scripts/configmaps/create-nginx-thrift-configmap.sh
kubectl create cm service-config-json --from-file=config/service-config.json  -n social-network

cd - >/dev/null
