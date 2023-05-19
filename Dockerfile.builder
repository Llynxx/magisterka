FROM openjdk:17-jdk-slim
RUN apt-get update -y && apt-get install maven -y
# Install Docker (for docker-in-docker)
RUN curl -fsSL https://get.docker.com | bash \
    && rm -rf /var/lib/apt/lists/*
RUN curl -Lo /tmp/helm.tgz "https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz" \
    && tar xvzOf /tmp/helm.tgz linux-amd64/helm > /bin/helm \
    && rm /tmp/helm.tgz \
    && chmod +x /bin/helm
RUN apt-get update && apt-get install -y zip