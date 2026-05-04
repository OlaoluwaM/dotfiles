
# Use the existing ollama image as the base image (https://hub.docker.com/r/ollama/ollama)
FROM ollama/ollama:latest

# Install curl, netcat, and ping
RUN apt-get update && \
  apt-get install -y curl iputils-ping netcat-traditional
