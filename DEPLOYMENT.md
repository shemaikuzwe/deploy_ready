# Deployment

## AWS EC2

The app runs on an AWS EC2 virtual machine using Ubuntu Server 24.04 LTS. I chose AWS because I am familiar with it.

- Server IP: `54.82.9.189`
- Allow inbound HTTP on port 80 in the EC2 security group.
- Restrict SSH access on port 22 to my own IP address.

## Install Docker

I installed Docker Engine by following Docker's official Ubuntu instructions: [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

## Pull and run the app

The container image is hosted on the GitHub Container Registry (GHCR): `ghcr.io/shemaikuzwe/deploy_ready`. 

On the EC2 instance, create a deployment directory, place `compose.yaml` and `nginx-default.conf` there, then create `.env` with the image and tag:

```dotenv
IMAGE=ghcr.io/shemaikuzwe/deploy_ready
IMAGE_TAG=latest
```

Start the production services:

```bash
docker compose -f compose.yaml pull
docker compose -f compose.yaml up -d
```

Nginx listens on port 80 and forwards requests to the app container. Check the deployment with:

```bash
curl -fsS http://54.82.9.189/health
```

View application logs with:

```bash
docker compose -f compose.yaml logs -f app
```

## Automated deployments

The GitHub Actions workflow runs the app tests, builds and pushes the image tagged with the commit SHA, then connects to the EC2 instance over SSH and updates `IMAGE_TAG` before running Compose.

The deploy job uses a local linux user `deploy` with only access to docker group.

