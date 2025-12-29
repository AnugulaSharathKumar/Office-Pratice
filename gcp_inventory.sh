#!/bin/bash

# ================================
# GCP Inventory Script
# ================================
# Collects:
# 1. Compute Engine VM details
# 2. Cloud Storage bucket details
# 3. IAM roles and bindings
# ================================

PROJECT_ID=$(gcloud config get-value project)
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="gcp_inventory_$DATE"

mkdir -p $OUTPUT_DIR

echo "Project ID: $PROJECT_ID"
echo "Saving output to: $OUTPUT_DIR"
echo "-----------------------------------"

# ================================
# 1. Compute Engine Instances
# ================================
echo "Collecting Compute Engine instance details..."

gcloud compute instances list \
  --format="table(name,zone,machineType,status,internalIP,externalIP)" \
  > $OUTPUT_DIR/compute_instances.txt

echo "✔ Compute Engine details saved"

# ================================
# 2. Storage Bucket Details
# ================================
echo "Collecting Cloud Storage bucket details..."

gsutil ls > $OUTPUT_DIR/storage_buckets.txt

# Get bucket-level details
for bucket in $(gsutil ls); do
  echo "Bucket: $bucket" >> $OUTPUT_DIR/storage_bucket_details.txt
  gsutil ls -L $bucket >> $OUTPUT_DIR/storage_bucket_details.txt
  echo "---------------------------------" >> $OUTPUT_DIR/storage_bucket_details.txt
done

echo "✔ Storage bucket details saved"

# ================================
# 3. IAM Roles and Policies
# ================================
echo "Collecting IAM policy details..."

gcloud projects get-iam-policy $PROJECT_ID \
  --format=json > $OUTPUT_DIR/iam_policy.json

echo "✔ IAM policy details saved"

# ================================
# Summary
# ================================
echo "-----------------------------------"
echo "GCP Inventory Collection Completed"
echo "Files generated:"
ls -lh $OUTPUT_DIR
