#!/bin/bash


# scales=(100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500)
# for s in ${scales[@]}; do
#     echo "Running scale $s"
#     for i in {1..5}
#     do
#       ./wrk/wrk -t1 -c1 -d 300s -s ../wrk2/scripts/hotel-reservation/user_workload/user_workload_$s.lua http://10.96.7.56:5000 --latency > /dev/null 2>&1 &
#       wrk_pid=$!
#       echo $wrk_pid
#       ssh h2 "sudo python3 /users/hazelnut/DeathStarBench/hotelReservation/scripts/latency_breakdown.py --proxy http -n 9000 -d 10"
#       kill -9 $wrk_pid
#       sleep 5
#     done
# done




scales=(1000 2000 3000)
for s in ${scales[@]}; do
    echo "Running scale $s"
    for i in {1..5}
    do
      ./wrk/wrk -t1 -c1 -d 300s -s ../wrk2/scripts/hotel-reservation/user_workload/user_workload_$s.lua http://10.96.7.56:5000 --latency > /dev/null 2>&1 &
      wrk_pid=$!
      echo $wrk_pid
      ssh h2 "sudo python3 /users/hazelnut/DeathStarBench/hotelReservation/scripts/latency_breakdown.py --proxy http -n 9000 -d 10"
      kill -9 $wrk_pid
      sleep 5
    done
done

scales=(4000 5000 6000 7000)

for s in ${scales[@]}; do
    echo "Running scale $s"
    for i in {1..5}
    do
      ./wrk/wrk -t1 -c1 -d 300s -s ../wrk2/scripts/hotel-reservation/user_workload/user_workload_$s.lua http://10.96.7.56:5000 --latency > /dev/null 2>&1 &
      wrk_pid=$!
      echo $wrk_pid
      ssh h2 "sudo python3 /users/hazelnut/DeathStarBench/hotelReservation/scripts/latency_breakdown.py --proxy http -n 7000 -d 10"
      kill -9 $wrk_pid
      sleep 5
    done
done


scale=(8000 9000 10000 11000 12000 13000 14000 15000 )

for s in ${scales[@]}; do
    echo "Running scale $s"
    for i in {1..5}
    do
      ./wrk/wrk -t1 -c1 -d 300s -s ../wrk2/scripts/hotel-reservation/user_workload/user_workload_$s.lua http://10.96.7.56:5000 --latency > /dev/null 2>&1 &
      wrk_pid=$!
      echo $wrk_pid
      ssh h2 "sudo python3 /users/hazelnut/DeathStarBench/hotelReservation/scripts/latency_breakdown.py --proxy http -n 6500 -d 10"
      kill -9 $wrk_pid
      sleep 5
    done
done

scale=(16000)
for s in ${scales[@]}; do
    echo "Running scale $s"
    for i in {1..5}
    do
      ./wrk/wrk -t1 -c1 -d 300s -s ../wrk2/scripts/hotel-reservation/user_workload/user_workload_$s.lua http://10.96.7.56:5000 --latency > /dev/null 2>&1 &
      wrk_pid=$!
      echo $wrk_pid
      ssh h2 "sudo python3 /users/hazelnut/DeathStarBench/hotelReservation/scripts/latency_breakdown.py --proxy http -n 6000 -d 10"
      kill -9 $wrk_pid
      sleep 5
    done
done

echo "Running scale 0"