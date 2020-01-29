
# Build GCP HTTPS Load Balancer with High Availability, Cloud DNS, Stackdriver Logging and SSL certificates

In this setup we're building a nodejs app running on port 8080 and exposed to the internet via a Kubernetes Loadbalancer type service on port 80.

Tools used:
* Terraform v0.12.20
* Docker
* Kubernetes

Terraform Infrastructure Layer:
* Google Kubernetes Cluster
* Kubernetes deployment for nodejs app
* Kubernetes service to expose app on the internet

Terraform Static Layer:
* Network and subnet in europe-west1 region
* Firewall ingress rule to allow NodePort traffic for debug purposes
* Reserve Global IP Address for HTTPS Load Balancer (Kubernetes service)
* DNZ Zone and records for domain name example.com


# Prerequisites

Prior to running terraform we need to have the following:
* GCP bucket to store terraform state files (eg: gs://secrets-terraform)
* Manually upload into secrets file the SSL certificates for your domain name
* Make certs available in the infra/include/certs folder
* Domain name example.com (Can be bought at https://domains.google.com)


# Setup authentication and authorization for terraform to access GCP project

Create a terraform GCP Service Account with Project Owner role permission.
Download the Service Account key locally.

Point GOOGLE_APPLICATION_CREDENTIALS env var to the key location on your machine.
```buildoutcfg
export GOOGLE_APPLICATION_CREDENTIALS=/full_path/account.json
```
# Build docker image

Please, follow instructions from Readme file at ../myapp

# Build GCP resources with terraform

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
# Configuring cluster access for kubectl

```buildoutcfg
export CLUSTER_NAME=myapp-gke-cluster
export CLUSTER_ZONE=europe-west1
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$CLUSTER_ZONE
```
# Tests

```buildoutcfg
siege -c250 -t100S https://example.com -v

URL=<PUBLIC_IP>
for i in {1..20}; do curl -s -m5 $URL; done
i=1; while [[ $i -le 20 ]]; do curl -s -m5 $URL; let i=i+1; done

```

# Destroy GCP resources with terraform

```buildoutcfg
cd infra
terraform init && terraform destroy -auto-approve

cd static
terraform init && terraform destroy -auto-approve
```