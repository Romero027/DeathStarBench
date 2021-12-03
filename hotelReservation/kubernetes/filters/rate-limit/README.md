# Rate Limit Filters

## Deploy filters
- kubectl apply -f .

## Check filters
- kubectl get envoyfilters

## Delete filters
- kubectl delete envoyfilters --all
- kubectl delete configmaps hotel-ratelimit-config
- kubectl delete deployment redis
- kubectl delete deployment ratelimit


