FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instala pacotes base
RUN apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Instala Terraform
ENV TERRAFORM_VERSION=1.8.4
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && mv terraform /usr/local/bin/ && rm terraform.zip

# Instala SOPS
ENV SOPS_VERSION=3.8.1
RUN curl -fsSL https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# Instala gcloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-cli

ENTRYPOINT ["/bin/bash"]
