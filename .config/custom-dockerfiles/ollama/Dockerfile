# Use the existing ollama image as the base image (https://hub.docker.com/r/ollama/ollama)
FROM ollama/ollama

# Add your environment variables
ENV OLLAMA_MAX_LOADED_MODELS=3

# Labels (https://docs.docker.com/config/labels-custom-metadata/ & https://docs.docker.com/reference/dockerfile/#label)
LABEL "com.centurylinklabs.watchtower.enable"="false"

# You can also add other configuration or setup commands here if needed
