# ${GITHUB_REPO_NAME}

Simple FastAPI backend deployed to a GCP VM using:
- Docker
- Terraform (creates VM, firewall, service account)
- GitHub Actions (OIDC / Workload Identity Federation, keyless)

## Quick notes

### Required GitHub repository secrets
- `GCP_PROJECT_ID` : your GCP project id
- `GCP_WORKLOAD_IDENTITY_PROVIDER` : the full provider resource (e.g. "projects/PROJECT_NUM/locations/global/workloadIdentityPools/POOL/providers/PROVIDER")
- `GCP_SERVICE_ACCOUNT_EMAIL` : service account email you granted the workload identity to (e.g. github-deployer@PROJECT_ID.iam.gserviceaccount.com)

### How it works
1. Push to main → GitHub Actions builds Docker image and pushes to Artifact Registry.
2. Actions uses OIDC to impersonate a GCP service account (no JSON keys).
3. Actions runs Terraform to create a VM whose startup script pulls the image and runs it.
4. Terraform outputs the VM public IP.

### Local testing
Build & run locally:
\`\`\`bash
docker build -t fastapi-local -f docker/Dockerfile .
docker run --rm -p 8000:8000 fastapi-local
# Visit http://localhost:8000
\`\`\`
