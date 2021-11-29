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
cd istio-1.11.4
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
curl "http://10.244.1.113:5000/recommendations?require=rate&lat=38.0235&lon=-122.095" 
curl "http://localhost:5000/hotels?inDate=2015-04-10&outDate=2015-04-11&lat=38.0235&lon=-122.095" # search hotel
curl "http://localhost:5000/user?username=Cornell_15&password=123654"

# Get envoy config
istioctl proxy-config listeners recommendationservice-7b57c9bd44-8bb5q --port 15006 -o json > OUTPUT
istioctl pc listener deploy/user-7b65fcdc7f-6gspl --port 15006 --address 0.0.0.0 -o yaml

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


# ssh between clients
cd ~/.ssh && echo "-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----" > id_rsa && sudo chmod -R 400 id_rsa && echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7K98OTK6gVEkmpclsezFBKR6BPTe13xK40F+VFgEqaG13XYKgO/j7L2VZkWfgpX4TtDyy9ZUudXnvGGfTyyGCxBV+vaDtB+C23I9hUYmVDNZ+Auoami8ost9ITlcNuhD5+huZft/N6Jd3P5ja7+nxMHKptrK2rQ7aa/5W3yn18wxWfJbg0ee1oZROgpnSgQBEGPkNv+j+FqsB7KThpKgc1OjDoyAfvvT9Uh2fJMzhLzM9XaRc9tuRMSkDb4yeNJ72lifp7tnWQPt6mVWikF0YxNeCWnSIwTjAmHrrn/kzyfYY9a2mUCy6iQtmy8YWQjueVTRwCnXbfm5kYPIN8utqFHb31nzSmiadGCwm/ntzrjfX61KZgqBdFq4W2P2/yUp2oJ6osEMcDBbOaD9Pqn1knwY1z+3EHjXZKTXktnK4VAt6UXZIRJRHPyeNt7DYywN43UT2dtPLl1DsUI/j7r4X4DPJLqRu/Mj9OJLrtTz/lbh+zIqAgcSyuyXiJViJK7Er6xMBFCQBMszRQfWCe72t13dGC/P6uEpp9vhtcQFyJFs8+CP69THNO7vaABDpPU3xJxaXkqnQaTC/C9fEZtsm9wgjzUxBcwWb45j4sX1Wew0fp1zU9DC0oI4WEI7p21ocsJi7yFNn/SrWxuVexJd4+rAjbhS8mZMqecS1gSIZQw== test@cloudlab.us" >> authorized_keys && echo "StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config