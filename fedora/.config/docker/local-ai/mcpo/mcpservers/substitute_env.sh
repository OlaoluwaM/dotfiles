#!/usr/bin/env bash

set -euo pipefail

# Path to the .env and config.json files
ENV_FILE="./.env"
EXAMPLE_CONFIG_FILE="./config.example.json"
OUTPUT_FILE="./config.json"

# Check if files exist
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found at $ENV_FILE"
  exit 1
fi

if [ ! -f "$EXAMPLE_CONFIG_FILE" ]; then
  echo "Error: config.json file not found at $EXAMPLE_CONFIG_FILE"
  exit 1
fi

# Create a temporary file for processing
TMP_FILE=$(mktemp)

# Copy the config file to the temporary file
cp "$EXAMPLE_CONFIG_FILE" "$TMP_FILE"

# Read each line from the .env file
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments
  if [[ -z "$line" || "$line" =~ ^# ]]; then
    continue
  fi

  # Extract the variable name and value
  if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
    VAR_NAME="${BASH_REMATCH[1]}"
    VAR_VALUE="${BASH_REMATCH[2]}"

    # Remove quotes if present
    VAR_VALUE="${VAR_VALUE#\"}"
    VAR_VALUE="${VAR_VALUE%\"}"

    echo "Substituting \${$VAR_NAME} with $VAR_VALUE"

    # Replace the placeholder in the temporary file
    # Use perl for more reliable regex replacement with special characters
    perl -pi -e "s/\\\$\\{$VAR_NAME\\}/$VAR_VALUE/g" "$TMP_FILE"
  fi
done <"$ENV_FILE"

# Move the temporary file to the output location
mv "$TMP_FILE" "$OUTPUT_FILE"

echo "Successfully created $OUTPUT_FILE with substituted environment variables."
