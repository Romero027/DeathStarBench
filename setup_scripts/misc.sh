# client-side throttling, not priority and fairness problem
# Source: https://stackoverflow.com/questions/66339069/kubectl-get-all-command-return-throttling-request
sudo chmod 777 -R ~/.kube/cache

# Build and push docker image
docker build -t xzhu0027/online_boutique_frontend:latest -f Dockerfile .
docker push xzhu0027/online_boutique_frontend:latest 