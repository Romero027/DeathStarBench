#!/bin/bash


scales=(100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500)

for s in ${scales[@]}; do
    echo "Running scale $s"
    for i in {1..5}
    do
      ./wrk/wrk -t1 -c1 -d 30s http://10.96.88.88:80 --latency -s echo-server/wrk-script/request_b/echo_workload_$s.lua | grep Minimum
      sleep 1
    done
done

echo "Running scale 0"


