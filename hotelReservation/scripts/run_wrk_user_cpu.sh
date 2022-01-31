#!/bin/bash

scales=(100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500)
#scales=(100)

for s in ${scales[@]}; do
    echo "Running scale $s"
    for i in {1..5}
    do
      ./wrk2/wrk -t2 -c100 -d300s -s echo-server/wrk-script/request_b/echo_workload_$.lua http://10.96.88.88:80 -R 40000 > /dev/null 2>&1 &
      sleep 10
      wrk_pid=$!
      echo $wrk_pid
      ssh h2 "sudo python3 /users/hazelnut/DeathStarBench/hotelReservation/scripts/cpu.py"
      kill -9 $wrk_pid
      sleep 5
    done
done

echo "Running scale 0"
