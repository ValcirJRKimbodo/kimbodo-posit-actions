# terraform-sops-gcloud

A custom Docker image bundled with:

- [Terraform](https://www.terraform.io/) (v1.8.4)
- [SOPS](https://github.com/getsops/sops) (v3.8.1)
- [Google Cloud CLI (gcloud)](https://cloud.google.com/sdk)

Ideal for use in GitHub Actions pipelines, GitLab CI, or local infrastructure-as-code execution on Google Cloud Platform, with secure secret handling using KMS + SOPS.

---

## What’s Included?

| Tool        | Version | Description                      |
|-------------|---------|----------------------------------|
| Terraform   | 1.8.4   | Infrastructure as code           |
| SOPS        | 3.8.1   | Encrypted secret management      |
| GCloud CLI  | latest  | Official Google Cloud CLI        |
| Base tools  | -       | curl, unzip, gnupg, etc.         |

---

## Example Usage with GitHub Actions

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    container:
      image: valcirjr/terraform-sops:latest  # Replace with your actual image

    steps:
      - uses: actions/checkout@v3

      - name: Configure GCP Credentials
        run: |
          echo "${{ secrets.GCP_KMS_SA_JSON }}" > /tmp/sa.json
          export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
          gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

      - name: Decrypt Terraform SA
        run: sops -d sa.enc.json > /tmp/terraform-sa.json

      - name: Run Terraform
        run: |
          terraform init
          terraform plan -out=tfplan
          terraform apply -auto-approve tfplan
```

---

## Local Execution

To test locally:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  valcirjr/terraform-sops:latest
```

Then you can run:

```bash
terraform init
sops -d sa.enc.json > terraform-sa.json
```

---

## Encrypting JSON with SOPS + GCP KMS

```bash
sops -e \
  --gcp-kms projects/YOUR_PROJECT_ID/locations/global/keyRings/YOUR_KEYRING/cryptoKeys/YOUR_KEY \
  terraform-sa.json > sa.enc.json
```

---

## Suggested Project Structure

```
.
├── envs/dev-gcp/
│   ├── main.tf
│   ├── sa.enc.json
│   └── terraform.tfvars
├── .github/
│   └── workflows/
│       └── terraform.yml
├── Dockerfile
└── README.md
```

---

## Requirements

- A GCP project with:
  - KMS key for encryption/decryption (`roles/cloudkms.cryptoKeyDecrypter`)
  - Service Account with a key JSON file
- GitHub Secret configured as `GCP_KMS_SA_JSON`
- `sa.enc.json` committed to the repo
- `.gitignore` must include `terraform-sa.json`

---

## Build Image Locally (Optional)

```bash
docker build -t terraform-sops .
```

(Optional) Publish to Docker Hub or GHCR:

```bash
docker tag terraform-sops valcirjr/terraform-sops:latest
docker push valcirjr/terraform-sops:latest
```

---

## Security

- The image does not expose any sensitive data or credentials.
- Decrypted secrets are stored temporarily in memory or ephemeral storage like `/tmp/`.
- Follows CI/CD best practices with scoped Service Account access.

---

## Contributions

Pull requests and improvements are welcome. This repository follows modern DevOps and cloud-native security practices.

---

## References

- [SOPS - Mozilla](https://github.com/getsops/sops)
- [Terraform - HashiCorp](https://www.terraform.io/)
- [Google Cloud KMS](https://cloud.google.com/kms)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)