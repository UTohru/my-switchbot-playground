FROM hashicorp/terraform:1.10.4

# Install Docker CLI and AWS CLI
RUN --mount=type=cache,target=/var/cache/apk \
    apk update && \
    apk add --no-cache \
    docker-cli \
    docker-cli-buildx \
    aws-cli \
    curl

# Install Google Cloud SDK
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz && \
  tar -xf google-cloud-cli-linux-x86_64.tar.gz && \
  ./google-cloud-sdk/install.sh --quiet
ENV PATH=/google-cloud-sdk/bin:${PATH}

ENTRYPOINT ["terraform"]
