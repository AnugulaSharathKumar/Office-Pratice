#!/bin/bash
set -euo pipefail

# =====================================================
# GCP Inventory Collection Script
# =====================================================
# Project  : project-3e800f45-77e7-454a-a2b
# Purpose  : Collect inventory details for
#            1. Compute Engine VMs
#            2. Cloud Storage Buckets
#            3. IAM Roles & Policies
# =====================================================

# -----------------------------
# Project Configuration
# -----------------------------
PROJECT_ID="project-3e800f45-77e7-454a-a2b"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="gcp_inventory_${PROJECT_ID}_${DATE}"

mkdir -p "$OUTPUT_DIR"

echo "====================================="
echo " GCP Inventory Collection Started"
echo " Project ID : $PROJECT_ID"
echo " Output Dir : $OUTPUT_DIR"
echo "====================================="

# -----------------------------
# 1. Compute Engine Inventory
# -----------------------------
echo "▶ Collecting Compute Engine VM details..."

gcloud compute instances list \
  --project="$PROJECT_ID" \
  --format="table(name,zone,machineType,status,internalIP,externalIP)" \
  > "$OUTPUT_DIR/compute_instances.txt"

echo "✔ Compute Engine inventory saved"

# -----------------------------
# 2. Cloud Storage Inventory
# -----------------------------
echo "▶ Collecting Cloud Storage bucket details..."

gsutil ls > "$OUTPUT_DIR/storage_buckets.txt"

# Clear details file before appending
> "$OUTPUT_DIR/storage_bucket_details.txt"

for bucket in $(gsutil ls); do
  {
    echo "Bucket: $bucket"
    gsutil ls -L "$bucket"
    echo "--------------------------------------"
  } >> "$OUTPUT_DIR/storage_bucket_details.txt"
done

echo "✔ Cloud Storage inventory saved"

# -----------------------------
# 3. IAM Policy Inventory
# -----------------------------
echo "▶ Collecting IAM policy details..."

gcloud projects get-iam-policy "$PROJECT_ID" \
  --format=json \
  > "$OUTPUT_DIR/iam_policy.json"

echo "✔ IAM policy inventory saved"

# -----------------------------
# Summary
# -----------------------------
echo "====================================="
echo " GCP Inventory Collection Completed"
echo " Generated files:"
ls -lh "$OUTPUT_DIR"
echo "====================================="
