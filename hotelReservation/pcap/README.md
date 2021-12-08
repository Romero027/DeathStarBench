# How to capture packets inside a kubernetes pod

## Commands
- Find the pod name 
- `kubectl exec -it <pod name> -- /bin/bash`
- `apt-get update`
- `apt-get install tcpdump`
- `tcpdump -i any -w result.pcap`
- Exit the pod and run `kubectl cp <pod name>:result.pcap result.pcap`

