#!/bin/bash
{
# Fetch the team name from instance metadata
TEAM_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/team_name" -H "Metadata-Flavor: Google")

echo "Team Name: $${TEAM_NAME}"

# Construct the secret name using the team name
SECRET_NAME="$${TEAM_NAME}-env"
echo "Secret Name: $${SECRET_NAME}"

# Fetch the .env content from GCP Secret Manager
ENV_CONTENT=$(gcloud secrets versions access latest --secret="$${SECRET_NAME}" --format='get(payload.data)' | tr '_-' '/+' | base64 -d)
echo "Env Fetched"

# Save the .env content to a file
echo "$${ENV_CONTENT}" > /usr/src/.env
echo "Env Saved at /usr/src/.env"

git clone https://github.com/dakshayahuja/clitix-poc.git
cd clitix-poc
docker compose up -d

} >> /var/log/setup.log 2>&1