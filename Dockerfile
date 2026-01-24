FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        sudo \
        xz-utils \
        zsh && \
    rm -rf /var/lib/apt/lists/*

# Allow existing ubuntu user to use sudo without password
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

RUN mkdir -p .config/home-manager
