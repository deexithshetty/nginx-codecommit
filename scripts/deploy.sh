#!/bin/bash

# Path to the kubeconfig file
export KUBECONFIG=/etc/kubernetes/admin.conf

# Define the variables
AWS_ACCOUNT_ID=891377233289
AWS_REGION=ap-south-1
REPOSITORY_NAME=nginx

# Function to get the latest image tag
get_latest_image_tag() {
  aws ecr describe-images --repository-name $REPOSITORY_NAME --region $AWS_REGION \
  --query 'sort_by(imageDetails,&imagePushedAt)[-1].imageTags[0]' --output text
}

IMAGE_TAG=$(get_latest_image_tag)

# Replace placeholders in the deployment YAML file
sed -e "s|\$AWS_ACCOUNT_ID|$AWS_ACCOUNT_ID|g" \
    -e "s|\$REGION|$AWS_REGION|g" \
    -e "s|\$REPOSITORY_NAME|$REPOSITORY_NAME|g" \
    -e "s|\$IMAGE_TAG|$IMAGE_TAG|g" \
    /tmp/manifests/deployment.yaml > /tmp/manifests/nginx-deployment.yaml

# Apply the processed Kubernetes deployment and log output
kubectl apply -f /tmp/manifests/nginx-deployment.yaml > /tmp/kubectl_apply.log 2>&1

