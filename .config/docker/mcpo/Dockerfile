# Use the existing mcpo image as the base image
FROM ghcr.io/open-webui/mcpo:main

# Install some dependencies
RUN apt-get update && \
  apt-get install -y curl iputils-ping netcat-traditional git

# Setup mcp-servers directory
WORKDIR /mcp-servers
COPY ./mcpservers/config.example.json .
COPY ./mcpservers/.env .
COPY ./mcpservers/substitute_env.sh .

RUN chmod +x substitute_env.sh
RUN ./substitute_env.sh

CMD ["--api-key", "top-secret", "--config", "/mcp-servers/config.json"]
