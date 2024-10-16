# ARM IAC

### Overview

```
✅ Infrastructure Setup: Terraform

✅ Containerization: Podman

✅ Container Orchestration: Kubernetes - Deployment, Service, Ingress

✅ CI: Github Actions

✅ CD: GitOps (ArgoCD)

✅ Deployment Platform: Kubernetes Cluster - EKS

✅ Configuration Managment: Helm

✅ Ingress Controller: Load Balancer - Exposed, DNS

🚧 Monitoring: Prometheus and Grafana
```

---

### Installation for MacOS

```
brew install terraform

brew install awscli

brew install kubernetes-cli

brew install argocd

brew install helm

brew install trivy
```

---

### Terraform

Create ECR and EKS cluster using Terraform

![terraform](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/terraform.png)

```
terraform fmt -recursive

terraform init

terraform validate

terraform plan

terraform apply -auto-approve

terraform destroy
```

---

### Automated Infrastructure using Jenkins

http://ec2-47-128-153-178.ap-southeast-1.compute.amazonaws.com:8080/

![jenkins-server](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/jenkins-server.png)

![ec2-contents](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/ec2-contents.png)

Get Jenkins admin password through SSM

```
sudo su ubuntu
cd
systemctl status jenkins.service
```

Allow Jenkins to run terraform actions

![terraform-in-jenkins](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/terraform-in-jenkins.png)

---

### Containerization

Setup

```
podman build -t arm-fe .
```

Launch: Development

```
podman run -p 5173:80 <image-id>
```

![podman-containerization](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/podman-containerization.png)

Launch: Manual test and push image to ECR

```
aws ecr get-login-password --region ap-southeast-1 --profile default | podman login --username AWS --password-stdin <ecr-repo-url>

podman build -t arm-fe . --platform=linux/amd64

podman tag arm-fe:v1 <ecr-repo-url>:v1

podman push <ecr-repo-url>:v1
```

![ecr](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/ecr.png)

---

### EKS

Setup: Configure kubectl

```
export AWS_PROFILE=devops
aws eks update-kubeconfig --region <aws-region> --name <cluster-name>
kubectl cluster-info
```

![kubectl-cluster-info](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/kubectl-cluster-info.png)

Launch: Manual deployment using Kubenetes Manifests

```
kubectl apply -k k8s
```

---

### Ingress controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml

kubectl get ing
```

Add Host name

```
sudo vim /etc/hosts
```

![host-name](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/host-name.png)

---

### Deploy Kubernetes Dashboard on EKS

Setup

```
DASHBOARD_VERSION="7.7.0"
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

kubectl create ns kubernetes-dashboard
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kubernetes-dashboard --version ${DASHBOARD_VERSION} --set service.type=LoadBalancer
```

Launch

To access Dashboard run:

```
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

NOTE: In case port-forward command does not work, make sure that kong service name is correct.

Check the services in Kubernetes Dashboard namespace using:

```
kubectl -n kubernetes-dashboard get svc
```

Dashboard will be available at: https://localhost:8443

```
kubectl create token eks-admin -n kube-system
```

![k8-dashboard](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/k8-dashboard.png)

---

### Helm

![helm](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/helm.png)

Setup: Copy k8s/manifests

```
helm create arm-fe-chart
```

Launch: Manual deployment using Helm

```
helm upgrade --install arm-fe ./helm/arm-fe-chart -f helm/arm-fe-chart/values.yaml
```

---

### Trivy Scan

```
trivy config helm/arm-fe-chart/

# Example of scan results

# Tests: 95 (SUCCESSES: 81, FAILURES: 14, EXCEPTIONS: 0)
# Failures: 14 (UNKNOWN: 0, LOW: 9, MEDIUM: 3, HIGH: 2, CRITICAL: 0)
```

![trivy-scan](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/trivy-scan.png)

Security fixes

![trivy-scan-port-80](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/trivy-scan-port-80.png)

---

### Configure ArgoCD on EKS

Setup

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

```
kubectl get pods -n argocd
kubectl get svc argocd-server -n argocd
```

![kubectl-argocd](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/kubectl-argocd.png)

Expose services to the LoadBalancer

```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Launch

ad8a3230c58a144a29d730c4b35c0255-116444762.ap-southeast-1.elb.amazonaws.com

To get the secret admin password

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

![argocd-setup](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/argocd-setup.png)

![argocd-app](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/argocd-app.png)

---

### Monitoring for EKS cluster: Prometheus and Grafana

Setup using Helm

```
helm repo add stable https://charts.helm.sh/stable
```

---

### Install Prometheus and Grafana

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana

helm repo list
```

![helm-repo-list](https://raw.githubusercontent.com/ARM-Capstone-Project/arm-iac/main/screenshots/helm-repo-list.png)

Expose services to the LoadBalancer

```
kubectl patch svc prometheus-server -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch svc grafana -p '{"spec": {"type": "LoadBalancer"}}'
```

Launch Prometheus

a94d55f1d27a446c2a1abf7236ba184a-1387041673.ap-southeast-1.elb.amazonaws.com

```
kubectl get svc prometheus-server
```

Launch Grafana

a0047fa462eba407c884cd73ff4442c4-778076486.ap-southeast-1.elb.amazonaws.com

```
kubectl get svc grafana
```

To get the secret admin password

```
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo
```
