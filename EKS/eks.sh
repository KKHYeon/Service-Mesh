kubectl apply -f apache-deployment.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f apache-svc.yaml
kubectl apply -f nginx-svc.yaml
kubectl apply -f ingress.yaml
kubectl apply -f ingress-controller-nlb.yaml
