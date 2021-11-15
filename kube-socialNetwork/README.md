# run method

0. minikube start
1. cd openshift/scripts && ./create-all-configmap.sh
2. cd ../
3. kubectl apply -f .
4. kubectl get svc // look for ip for service: nginx-thrift replace it to ../scripts/init\_social\_graph.py line 137
5. ubuntuclient=$(kubectl -n social-network get pod | grep ubuntu-client- | cut -f 1 -d " ")
6. kubectl cp /home/bowen/system-network/DeathStarBench social-network/"${ubuntuclient}":/root
7. log into ubuntuclient pod
8. cd /root/DeathStarBench/socialNetwork
9. python scripts/init\_social\_graph.py
10. cd wrk2
11. make clean && make
12. ./wrk -D exp -t 2 -c 4 -d 60 -L -s ./scripts/social-network/compose-post.lua http://nginx-thrift.social-network.svc.cluster.local:8080/wrk2-api/post/compose -R 5
13. kubectl port-forward jaeger-agent-<pod id> 16686:16686
14. on host with browser, ssh -L 16686:localhost:16686 hostIPAddress	
