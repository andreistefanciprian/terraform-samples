
# Building an HTTPS webserver with High Availability in GCP + Cloud NAT + Cloud DNS + Stackdriver Logging

In this setup we're building the components mentioned below using terraform.

Terraform Infrastructure Layer:
- Compute Engine templates for Ubuntu VM that is going to have NGINX installed via startup script
- Single Zone Managed Instance Group with Autoscaling Enabled for each region
- HTTPS Global LB
- Stackdriver logging for startup and nginx logs

Terraform Static Layer:
- Network and subnet in us-central1 and europe-west1 regions
- Firewall ingress rule to allow ICMP, SSH and HTTPS traffic
- Reserve Global IP Address for HTTPS Load Balancer
- Cloud NAT and Router for each zone
- DNZ Zone and records for domain name devopsnation.co.uk


# Prerequisites
Prior to running terraform we need to have the following:
- GCP bucket to store terraform state files (eg: gs://secrets-terraform)
- GCP bucket to upload nginx.conf and startup.sh files (eg: gs://secrets-app)
- Manually upload into secrets file the SSL certificates for your domain name
- Make certs available in the infra/include/certs folder
- Domain name devopsnation.co.uk (Can be bought at https://domains.google.com)


# Setup authentication and authorization for terraform to access GCP project
Create a terraform GCP Service Account with Project Owner role permission.
Download the Service Account key locally.
Point GOOGLE_APPLICATION_CREDENTIALS env var to the key location on your machine.
```buildoutcfg
export GOOGLE_APPLICATION_CREDENTIALS=/full_path/account.json
```

# Build and destroy GCP resources with terraform
```buildoutcfg

# Build GCP resources for static layer
cd static
terraform init
terraform plan
terraform apply -auto-approve

# Build GCP resources for infra layer
cd infra
terraform init
terraform plan
terraform apply -auto-approve

# Destroy GCP resources across all layers
cd infra
terraform init
terraform destroy -auto-approve

cd static
terraform init
terraform destroy -auto-approve

```

# Test HTTPS LB autoscales and uses servers in all regions

```buildoutcfg
siege -c250 -t100S https://devopsnation.co.uk -v
```