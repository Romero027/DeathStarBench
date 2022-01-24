#!/bin/bash


scales=(1 2 4 8 16 32 64 128 256 512 1000 2000 4000 8000 16000)

for s in ${scales[@]}; do
    echo "Running scale $s"
    for i in {1..5}
    do
      ./wrk/wrk -t1 -c1 -d 10s http://10.96.88.88:80 --latency -s echo-server/wrk-script/echo_workload_$s.lua | grep 50%
      sleep 1
    done
done

echo "Running scale 0"


