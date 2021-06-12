FROM ubuntu:20.04

USER root

ARG DEBIAN_FRONTEND=noninteractive

ARG DOCKER_VERSION
ENV DOCKER_VERSION=$DOCKER_VERSION

ARG DOCKER_COMPOSE_VERSION
ENV DOCKER_COMPOSE_VERSION=$DOCKER_COMPOSE_VERSION

ARG TERRAFORM_VERSION
ENV TERRAFORM_VERSION=$TERRAFORM_VERSION

ARG TERRAGRUNT_VERSION
ENV TERRAGRUNT_VERSION=$TERRAGRUNT_VERSION

ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=$KUBECTL_VERSION

ARG HELM_VERSION
ENV HELM_VERSION=$HELM_VERSION

RUN set -x && \
    apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    build-essential \
    software-properties-common \
    unzip \
    net-tools \
    wget \
    curl \
    python3 \
    python3-dev \
    python3-pip \
    jq \
    gettext-base \
    git \
    tree \
    wireguard-tools \
    gnupg2 \
    sshpass \
    openssh-client && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y \
    containerd.io \
    docker-ce=5:$DOCKER_VERSION~3-0~$(lsb_release -is | tr '[:upper:]' '[:lower:]')-$(lsb_release -cs) \
    docker-ce-cli=5:$DOCKER_VERSION~3-0~$(lsb_release -is | tr '[:upper:]' '[:lower:]')-$(lsb_release -cs) && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

RUN set -x && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
    add-apt-repository ppa:rmescandon/yq && \
    apt update && \
    apt install -y yq && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    python3 -m pip install --upgrade --no-cache-dir pip cffi jmespath setuptools shyaml

RUN set -x && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    rm awscliv2.zip && \
    ./aws/install

RUN set -x && \
    cd /tmp && \
    curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/terraform && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN set -x && \
    wget "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" && \
    mv terragrunt_linux_amd64 /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

RUN set -x && \
    wget https://github.com/peak/s5cmd/releases/download/v1.2.1/s5cmd_1.2.1_Linux-64bit.tar.gz && \
    tar -xf s5cmd_1.2.1_Linux-64bit.tar.gz s5cmd && \
    rm -fv s5cmd_1.2.1_Linux-64bit.tar.gz && \
    mv s5cmd /usr/local/bin/s5cmd && \
    chmod +x /usr/local/bin/s5cmd

RUN set -x && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/bin/kubectl

RUN set -x && \
    chmod +x /usr/bin/kubectl

RUN set -x && \
    curl -LJO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    cd linux-amd64 && \
    chmod +x helm && \
    mv helm /usr/bin/helm && \
    rm -rf ../linux-amd64

RUN set -x && \
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin/

RUN set -x && \
    curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    mv aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

RUN set -x && \
    curl --version && \
    envsubst --version && \
    python3 --version && \
    pip --version && \
    shyaml --version && \
    jq -V && \
    yq -V && \
    aws --version && \
    docker -v && \
    docker-compose -v && \
    terraform --version && \
    terragrunt --version && \
    s5cmd version && \
    kubectl version --client && \
    helm version && \
    eksctl version && \
    aws-iam-authenticator version

ENTRYPOINT ["/bin/bash", "-c"]

