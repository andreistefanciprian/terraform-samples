# Build app image

Bellow are the steps for building a nodejs container app with Google cloud build (https://cloud.google.com/cloud-build/)
The image will be published to Google Container Registry (https://cloud.google.com/container-registry).

## Prerequisites

• Have GCP SDK installed (https://cloud.google.com/sdk/install)

## Build and publish docker image

```buildoutcfg
PROJECT_ID=<PROJECT-ID>

# Build and push image to Google Container Register
gcloud builds submit --config cloudbuild.yaml .

```