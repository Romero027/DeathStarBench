# Hotel Reservations on OpenShift 4.x

## Pre-requirements

- A running Kubernetes cluster is needed.
- Pre-requirements mentioned [here](https://github.com/delimitrou/DeathStarBench/blob/master/hotelReservation/README.md) should be met.

## Running the Hotel Reservation application

### Before you start

- [OPTIONAL] Build and push docker images if you made changes.
  - `<path-of-repo>/hotelReservation/kubernetes/scripts/build-docker-images.sh`, currently all images exists in the `xzhu0027/<image-name>`.
  if you intend to change it, remember to change the username in the build script and also all deployments as well.
- [Kubernetes] Change the Nodename of all deployment and persistent volume. 
- [Istio] Install [istioctl](https://istio.io/latest/docs/setup/getting-started/)
  
### Deploy services

- `kubectl apply -f service`
- `kubectl apply -f pv`
- `kubectl apply -f pvc`
- `kubectl apply -f mongodb`
- `kubectl apply -f memcached`
- `kubectl apply -f deployment`


### Istio Configs

- Install: `istioctl install --set profile=default -y`
- Enable auto injection: `kubectl label namespace default istio-injection=enabled`
- Disable auto injection: `kubectl label namespace default istio-injection-`
- Config proxies:
  - Change protocol prefix in service yaml files [Reference](https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/)
  - Get proxy config: `istioctl proxy-config listeners [pod-name] --port [15006(inbound)/15001(outbound)] -o json`


### Prepare HTTP workload generator

- Review the URL's embedded in `wrk2_lua_scripts/mixed-workload_type_1.lua` to be sure they are correct for your environment.
  The current value of `http://frontend.hotel-res.svc.cluster.local:5000` is valid for a typical "on-cluster" configuration.
- To use an "on-cluster" client, copy the necessary files to `hr-client`, and then log into `hr-client` to continue:
  - `hrclient=$(oc get pod | grep hr-client- | cut -f 1 -d " ")`
  - `oc cp <path-of-repo> hotel-res/"${hrclient}":<path-of-repo>`
    - e.g., `oc cp /root/DeathStarBench hotel-res/"${hrclient}":/root`
  - `oc rsh deployment/hr-client`

### Running HTTP workload generator

### wrk2
 
##### Template
```bash
cd <path-of-repo>/hotelReservation
./wrk2/wrk -D exp -t <num-threads> -c <num-conns> -d <duration> -L -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://[cluster-ip]:5000 -R <reqs-per-sec><reqs-per-sec>
```

##### Example
```bash
cd /root/DeathStarBench/hotelReservation
./wrk -D exp -t 2 -c 2 -d 30 -L -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://[cluster-ip]:5000 -R 2 
```

### wrk


```bash
git clone https://github.com/wg/wrk # run make
./wrk/wrk -t1 -c1 -d60s -s ./wrk2/scripts/hotel-reservation/mixed-workload_type_1.lua http://[cluster-ip]:5000 --latency
```


### View Jaeger traces

Use `oc -n hotel-res get ep | grep jaeger-out` to get the location of jaeger service.

View Jaeger traces by accessing:
- `http://<jaeger-ip-address>:<jaeger-port>`  (off cluster)
- `http://jaeger.hotel-res.svc.cluster.local:6831`  (on cluster)


### Tips

- If you are running on-cluster, you can use the following command to copy files off of the client.
e.g., to copy the results directory from the on-cluster client to the local machine:
  - `hrclient=$(oc get pod | grep hr-client- | cut -f 1 -d " ")`
  - `oc cp hotel-res/${hrclient}:/root/DeathStarBench/hotelReservation/openshift/results /tmp`


kubectl apply -f <(istioctl kube-inject -f deployment/user-deployment.yaml)
