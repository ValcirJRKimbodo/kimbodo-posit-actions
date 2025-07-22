FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instala pacotes base
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates \
    git \
    apt-transport-https \
    bash \
    tar \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Instala Terraform
ENV TERRAFORM_VERSION=1.8.4
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && mv terraform /usr/local/bin/ && rm terraform.zip

# Instala SOPS
ENV SOPS_VERSION=3.8.1
RUN curl -fsSL https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# Instala Google Cloud CLI
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && apt-get install -y google-cloud-cli

# Instala Helm
ENV HELM_VERSION=3.14.0
RUN curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
    tar -xzf helm.tar.gz && mv linux-amd64/helm /usr/local/bin/ && \
    rm -rf linux-amd64 helm.tar.gz

# Instala Helmfile (versão estável com tar.gz disponível)
ENV HELMFILE_VERSION=0.171.0
RUN curl -fsSL https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz -o helmfile.tar.gz && \
    tar -xzf helmfile.tar.gz && mv helmfile /usr/local/bin/ && rm helmfile.tar.gz

# Instala helm-secrets plugin
RUN helm plugin install https://github.com/jkroepke/helm-secrets

ENTRYPOINT ["/bin/bash"]
