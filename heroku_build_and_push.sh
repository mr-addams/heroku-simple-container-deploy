#!/bin/bash

# Stop the script on any errors
set -e

# Check for git installation
if ! command -v git &> /dev/null
then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

# Check for docker installation
if ! command -v docker &> /dev/null
then
    echo "Error: Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check for heroku-cli installation
if ! command -v heroku &> /dev/null
then
    echo "Error: Heroku CLI is not installed. Please install Heroku CLI and try again."
    exit 1
fi

# Variables
APP_NAME="my-heroku-app"            # Specify the name of your Heroku app here or dynamically set it
HEROKU_API_KEY="<Your Heroku API Key>" # Replace with your Heroku API key or use it from secrets
HEROKU_APP_NAME="$APP_NAME"
SERVICE_NAME="web"                  # Service name for a single container
DOCKERFILE_PATH="docker/Dockerfile"  # Path to your Dockerfile (change if needed)

# Check if Heroku app exists
if ! heroku apps:info --app $HEROKU_APP_NAME > /dev/null 2>&1; then
    echo "Creating Heroku app: $HEROKU_APP_NAME"
    heroku apps:create $HEROKU_APP_NAME
else
    echo "Heroku app $HEROKU_APP_NAME already exists."
fi

# Set Heroku stack to container
heroku stack:set container --app $HEROKU_APP_NAME

# Build Docker container and push to Heroku
echo "Building Docker container using Dockerfile at $DOCKERFILE_PATH..."
docker build -f $DOCKERFILE_PATH -t registry.heroku.com/${HEROKU_APP_NAME}/${SERVICE_NAME} .

echo "Pushing Docker image to Heroku..."
docker push registry.heroku.com/${HEROKU_APP_NAME}/${SERVICE_NAME}

# Release container on Heroku
echo "Releasing container on Heroku..."
heroku container:release $SERVICE_NAME --app $HEROKU_APP_NAME

echo "Deployment completed successfully."

