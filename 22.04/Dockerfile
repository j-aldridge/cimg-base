# vim:set ft=dockerfile:

# Do not edit individual Dockerfiles manually. Instead, please make changes to the Dockerfile.template, 
# which will be used by the build script to generate Dockerfiles.

FROM ubuntu:24.04

LABEL maintainer="CircleCI Execution Team <eng-execution@circleci.com>"

# Change default shell for RUN from Dash to Bash
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=dumb \
    PAGER=cat \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Configure APT and create CircleCI user
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci && \
    echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci && \
    apt-get update && apt-get install -y \
        curl \
        locales \
        sudo && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid=1002 circleci && \
    useradd --uid=1001 --gid=circleci --create-home circleci && \
    echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci && \
    echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep && \
    sudo -u circleci mkdir -p /home/circleci/{project,bin,.local/bin}

# Install Dockerize
RUN arch=$(uname -p) && \
    dockerizeArch=${arch/x86_64/x86_64} && \
    dockerizeArch=${arch/aarch64/arm64} && \
    curl -sSL --fail --retry 3 -o /usr/local/bin/dockerize \
        "https://github.com/powerman/dockerize/releases/download/v0.8.0/dockerize-linux-${dockerizeArch}" && \
    chmod +x /usr/local/bin/dockerize && \
    dockerize --version

# Install system dependencies
RUN noInstallRecommends="--no-install-recommends" && \
    apt-get update && apt-get install -y $noInstallRecommends \
        autoconf \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        file \
        gettext-base \
        gnupg \
        gzip \
        jq \
        libcurl4-openssl-dev \
        libmagic-dev \
        libmariadb-dev \
        libmariadb-dev-compat \
        libpq-dev \
        libssl-dev \
        libsqlite3-dev \
        lsof \
        make \
        nano \
        net-tools \
        openssh-client \
        parallel \
        pkg-config \
        postgresql-client \
        python-is-python3 \
        retry \
        shellcheck \
        software-properties-common \
        sudo \
        tar \
        tzdata \
        unzip \
        vim \
        wget \
        zip && \
    add-apt-repository ppa:git-core/ppa && apt-get install -y git && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs && \
    git version && git lfs version && \
    python --version && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -sSL "https://raw.githubusercontent.com/CircleCI-Public/cimg-node/main/ALIASES" -o nodeAliases.txt && \
    NODE_VERSION=$(grep "lts" ./nodeAliases.txt | cut -d "=" -f 2-) && \
    curl -L -o node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" && \
    sudo tar -xJf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz nodeAliases.txt && \
    sudo ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin && \
    docker --version && \
    rm -rf /var/lib/apt/lists/*

# Install yq
RUN yq_arch=$(dpkg --print-architecture) && \
    curl -sSL "https://github.com/mikefarah/yq/releases/download/v4.42.1/yq_linux_$yq_arch.tar.gz" | \
    tar -xz -C /usr/local/bin && \
    mv /usr/local/bin/yq{_linux_$yq_arch,}

# Switch to circleci user
USER circleci

# Install Bun
RUN curl -sSL https://bun.sh/install | bash

# Run final setup and tests as circleci user
RUN whoami && \
    git config --global --add safe.directory '*'

# Match the default CircleCI working directory
WORKDIR /home/circleci/project
