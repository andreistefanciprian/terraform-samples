
# Description

In this scenario we're building a nodejs app that can be accessed via a domain name, http://devopsnation.co.uk.
The app is exposed to the internet via a Kubernetes Loadbalancer type service.
The app is built using Docker with Google Cloud Build (https://cloud.google.com/cloud-build/)
The app is deployed as a kubernetes deployment with an horizontal pod autoscaler attached.
After all resources are built we perform a load test on the kubernetes service to trigger the horizontal pod autoscaler.
The GCP cloud infrastructure is being automated with terraform.

#### Terraform state layers description

Terraform Static Layer:
* Network and subnet in europe-west1 region
* Firewall ingress rule to allow NodePort traffic for debug purposes
* Reserve Global IP Address for HTTPS Load Balancer (Kubernetes service)
* DNZ Zone and records for domain name devopsnation.co.uk

Terraform Infrastructure Layer:
* Google Kubernetes regional Cluster, with nodes in every region zone
* Kubernetes deployment, LoadBalancer service and Horizontal Pod Autoscaler for nodejs app

#### Tools used

* Cloud Build
* Terraform v0.12.20
* Docker
* Kubernetes
* siege (http load test)

#### Prerequisites

Prior to running terraform we need to have the following:
* GCP bucket to store terraform state files (eg: gs://secrets-terraform)
* Manually upload into secrets file the SSL certificates for your domain name (TBD)
* Make certs available in the infra/include/certs folder (TBD)
* Domain name devopsnation.co.uk (managed from https://domains.google.com)


#### Setup authentication and authorization for terraform to access GCP project

Create a terraform GCP Service Account with Project Owner role permission.
Download the Service Account key locally.

Point GOOGLE_APPLICATION_CREDENTIALS env var to the key location on your machine:

```buildoutcfg
export GOOGLE_APPLICATION_CREDENTIALS=/full_path/account.json
```

#### Build docker image

Please, follow instructions from README file at ../myapp

#### Build GCP resources with terraform

```buildoutcfg

# Build GCP resources for static layer
cd static
terraform init
terraform plan && terraform apply -auto-approve

# Note: Once DNS zone is built make sure you have the same name servers in your domain name manager app (https://domains.google.com/)

# Build GCP resources for infra layer
cd infra
terraform init
terraform plan && terraform apply -auto-approve

```
#### Configuring cluster access for kubectl

```buildoutcfg
export CLUSTER_NAME=myapp-gke-cluster
export CLUSTER_ZONE=europe-west1
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$CLUSTER_ZONE
```

#### Load test

```buildoutcfg

# load test app service
URL=http://devopsnation.co.uk
siege -c150 -t1M $URL -v

# observe hpa
kubectl get hpa
kubectl get pods -w
kubectl top pods
kubectl logs POD_NAME -f --timestamps

# other debug commands
URL=$(kubectl get svc myapp -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
for i in {1..20}; do curl -s -m5 $URL; done
i=1; while [[ $i -le 20 ]]; do curl -s -m5 $URL; let i=i+1; done

```

#### Destroy GCP resources with terraform

```buildoutcfg
cd infra
terraform init && terraform destroy -auto-approve

cd static
terraform init && terraform destroy -auto-approve
```