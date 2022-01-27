#!/bin/bash

# TCP proxy
kubectl apply -f service-tcp 

# gRPC proxy
kubectl apply -f service
kubectl apply -f pv
kubectl apply -f pvc
kubectl apply -f mongodb/mongodb-user-deployment.yaml
kubectl apply -f mongodb/mongodb-reservation-deployment.yaml
kubectl apply -f memcached/memcached-reservation-deployment.yaml
kubectl apply -f deployment/consul-deployment.yaml
kubectl apply -f deployment/user-deployment.yaml
kubectl apply -f deployment/frontend-deployment.yaml
kubectl apply -f deployment/reservation-deployment.yaml

# Curl
curl "http://10.96.7.56:5000/user?username=Cornell_15&password=123654"

# wrk (need to build wrk first)
../wrk/wrk -t1 -c1 -d400s -s ./wrk2/scripts/hotel-reservation/reservation_workload.lua http://10.96.7.56:5000 --latency
