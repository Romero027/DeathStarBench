# install docker
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# install minikube
#curl -LO https://github.com/kubernetes/minikube/releases/download/v1.16.0/minikube-linux-amd64
curl -LO https://github.com/kubernetes/minikube/releases/download/v1.21.0/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# install kubectl
#curl -LO https://dl.k8s.io/release/v1.16.0/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

sudo usermod -aG docker $USER && newgrp docker
minikube start # or minikube start --memory 8192 --cpus 2 if you need more cpu&memory

# install istio
curl -k -L https://istio.io/downloadIstio | sh -
cd istio-1.12.0
export PATH=$PWD/bin:$PATH
istioctl x precheck
istioctl install --set profile=default -y
# turn on
kubectl label namespace default istio-injection=enabled
# turn off
kubectl label namespace default istio-injection-


# install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# start docker-compose
sudo docker-compose build
sudo docker-compose up -d
sudo docker-compose stop

source <(kubectl completion bash)
source <(kubectl completion bash | sed s/kubectl/k/g)

# test hotel
curl "http://localhost:5000/recommendations?require=rate&lat=38.0235&lon=-122.095" # recommendation
curl "http://localhost:5000/hotels?inDate=2015-04-10&outDate=2015-04-11&lat=38.0235&lon=-122.095" # search hotel
curl "http://localhost:5000/user?username=Cornell_15&password=123654" # get suer
wr# reserve

# Get envoy config
istioctl proxy-config listeners recommendationservice-7b57c9bd44-8bb5q --port 15006 -o json > OUTPUT
istioctl pc listener deploy/user --port 15006 --address 0.0.0.0 -o yaml

# Update istio envirnoment variable -> update pilot ev
# Reference: https://github.com/istio/istio/issues/29395
./istioctl manifest apply --set PILOT_ENABLE_MONGO_FILTER="true"

# disable injection
spec:
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "false"

# FlameGraphf
# sudo perf record -F 99 -a -g -- sleep 40
# sudo perf script > out.perf
# sudo ./stackcollapse-perf.pl out.perf > out.folded
# ./flamegraph.pl out.folded > kernel.svg
sudo su
git clone https://github.com/brendangregg/FlameGraph.git
cd FlameGraph
perf record -F 99 -a -g -- sleep 40
perf script | ./stackcollapse-perf.pl | ./flamegraph.pl > perf.svg

./wrk/wrk -t1 -c1 -d400s -s ./wrk2/scripts/hotel-reservation/search_hotel_workload.lua http://10.96.7.56:5000 --latency

# client-side throttling, not priority and fairness problem
# Source: https://stackoverflow.com/questions/66339069/kubectl-get-all-command-return-throttling-request
sudo chmod 777 -R ~/.kube/cache

# Build and push docker image
docker build -t xzhu0027/online_boutique_frontend:latest -f Dockerfile .
docker push xzhu0027/online_boutique_frontend:latest 

# Capture packet in a kubernetes pod
docker inspect <container-id> | grep Pid
nsenter -t <pid> -n tcpdump -i any -w result.pcap


# Get Envoy version in Istio
kubectl exec -it user-964f65f95-8bh2g -c istio-proxy -n default  -- pilot-agent request GET server_info --log_as_json | grep "version"


# strace 
sudo strace -p <pid> -f -e readv -o <output file>








Running cmd: python3 ./funclatency.py -p 569120 process_backlog -d 5 -t 0
Running cmd: python3 ./funclatency.py -p 569120 do_readv -d 5 -t 0
Running cmd: python3 ./funclatency.py -p 569120 do_writev -d 5 -t 0
Running cmd: python3 ./funclatency.py -p 569120 ep_send_events_proc -d 5 -t 0
Running cmd: python3 ./funclatency.py -p 569120 /proc/569120/root/usr/local/bin/envoy:*onReadReady* -d 5 -t 6592
Running cmd: python3 ./funclatency.py -p 569120 /proc/569120/root/usr/local/bin/envoy:*onWriteReady* -d 5 -t 41332