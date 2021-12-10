# run method

0. minikube start
1. cd openshift/scripts && ./create-all-configmap.sh
2. cd ../
3. kubectl apply -f .
4. kubectl get svc
5. look for ip for service: nginx-thrift replace it to ../scripts/init\_social\_graph.py line 137
6. ubuntuclient=$(kubectl -n social-network get pod | grep ubuntu-client- | cut -f 1 -d " ")
7. kubectl cp 'abs path of DeathStarBench' social-network/"${ubuntuclient}":/root
8. log into ubuntuclient pod, then inside pods running the rest of commands
9. cd /root/DeathStarBench/kube-socialNetwork
10. python scripts/init\_social\_graph.py
11. cd wrk2
12. make clean && make
13. ./wrk -D exp -t 2 -c 4 -d 60 -L -s ./scripts/social-network/compose-post.lua http://nginx-thrift.social-network.svc.cluster.local:18080/wrk2-api/post/compose -R 5
14. kubectl port-forward jaeger-agent-<pod id> 16686:16686 # for viewing traces
15. on host with browser, ssh -L 16686:localhost:16686 hostIPAddress	
  
16. For Istio, simply allow auto-injection to namespace social-network
17. make sure ubuntuclient is not injected, user does not need a proxy


- ` kubectl create namespace social-network && kubectl config set-context --current --namespace=social-network` 
- `cd openshift/scripts && ./create-all-configmap.sh` 
- `cd ..`
- `kubectl apply -f .` 
