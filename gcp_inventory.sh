#!/bin/bash
set -euo pipefail

# =====================================================
# Enhanced GCP Inventory Script
# =====================================================
# Project  : project-3e800f45-77e7-454a-a2b
# Purpose  :
#   1. Collect RUNNING & STOPPED VM details
#   2. Collect Cloud Storage bucket details
#   3. Collect IAM roles AND who has access
# =====================================================

PROJECT_ID="project-3e800f45-77e7-454a-a2b"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="gcp_inventory_${PROJECT_ID}_${DATE}"

mkdir -p "$OUTPUT_DIR"

echo "====================================="
echo " Project ID : $PROJECT_ID"
echo " Output Dir : $OUTPUT_DIR"
echo "====================================="

# -----------------------------------------------------
# Validate access
# -----------------------------------------------------
echo "▶ Validating project access..."
gcloud projects describe "$PROJECT_ID" >/dev/null
echo "✔ Project access verified"

# -----------------------------------------------------
# 1. Compute Engine Inventory (ALL STATES)
# -----------------------------------------------------
echo "▶ Collecting Compute Engine instances (ALL STATES)..."

# JSON for reliability
gcloud compute instances list \
  --project="$PROJECT_ID" \
  --format=json \
  > "$OUTPUT_DIR/compute_instances_all.json"

# Human-readable split
gcloud compute instances list \
  --project="$PROJECT_ID" \
  --filter="status=RUNNING" \
  --format="table(name,zone,machineType,status,internalIP,externalIP)" \
  > "$OUTPUT_DIR/compute_instances_running.txt" || true

gcloud compute instances list \
  --project="$PROJECT_ID" \
  --filter="status=TERMINATED" \
  --format="table(name,zone,machineType,status,internalIP,externalIP)" \
  > "$OUTPUT_DIR/compute_instances_stopped.txt" || true

echo "✔ Compute Engine inventory collected"

# -----------------------------------------------------
# 2. Cloud Storage Inventory
# -----------------------------------------------------
echo "▶ Collecting Cloud Storage buckets..."

gsutil ls > "$OUTPUT_DIR/storage_buckets.txt" || true
> "$OUTPUT_DIR/storage_bucket_details.txt"

for bucket in $(gsutil ls 2>/dev/null || true); do
  {
    echo "Bucket: $bucket"
    gsutil ls -L "$bucket"
    echo "--------------------------------------"
  } >> "$OUTPUT_DIR/storage_bucket_details.txt"
done

echo "✔ Cloud Storage inventory collected"

# -----------------------------------------------------
# 3. IAM Inventory – Roles & Access
# -----------------------------------------------------
echo "▶ Collecting IAM roles and access details..."

# Raw IAM policy
gcloud projects get-iam-policy "$PROJECT_ID" \
  --format=json \
  > "$OUTPUT_DIR/iam_policy_raw.json"

# Human-readable IAM access matrix
gcloud projects get-iam-policy "$PROJECT_ID" \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)" \
  > "$OUTPUT_DIR/iam_who_has_access.txt"

# Group by member (who → what access)
gcloud projects get-iam-policy "$PROJECT_ID" \
  --flatten="bindings[].members" \
  --format="table(bindings.members,bindings.role)" \
  > "$OUTPUT_DIR/iam_member_access_matrix.txt"

echo "✔ IAM access inventory collected"

# -----------------------------------------------------
# Summary
# -----------------------------------------------------
echo "====================================="
echo " GCP Inventory Collection Completed"
echo " Files generated:"
ls -lh "$OUTPUT_DIR"
echo "====================================="

