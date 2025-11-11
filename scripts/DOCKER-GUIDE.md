# Docker Deployment Guide

This guide covers building and deploying the Task Manager application using Docker.

## Prerequisites

- Docker installed on your local machine
- Docker Hub account (or AWS ECR)
- EC2 instance with Docker installed

## Phase 3: Local Docker Testing

### Build Docker Image

```bash
cd Frontend
docker build -t task-manager:latest .
```

The build uses a multi-stage Dockerfile:
1. **Stage 1:** Builds the React app using Node.js
2. **Stage 2:** Serves the built files with Nginx

### Run Container Locally

```bash
# Run on port 3000
docker run -d -p 3000:80 --name task-manager task-manager:latest

# Or use Docker Compose
docker-compose up -d
```

Visit `http://localhost:3000` to test the application.

### Useful Docker Commands

```bash
# View running containers
docker ps

# View container logs
docker logs task-manager
docker logs -f task-manager  # Follow logs

# Stop container
docker stop task-manager

# Remove container
docker rm task-manager

# Remove image
docker rmi task-manager:latest

# Enter container shell
docker exec -it task-manager sh

# View image details
docker inspect task-manager:latest

# Check image size
docker images task-manager

# Using Docker Compose
docker-compose up -d        # Start
docker-compose down         # Stop and remove
docker-compose logs -f      # View logs
docker-compose restart      # Restart
```

## Docker Hub Setup

### Option 1: Docker Hub (Recommended for Learning)

1. **Create Docker Hub Account:** https://hub.docker.com

2. **Login to Docker Hub:**
   ```bash
   docker login
   ```

3. **Tag your image:**
   ```bash
   docker tag task-manager:latest YOUR_DOCKERHUB_USERNAME/task-manager:latest
   ```

4. **Push to Docker Hub:**
   ```bash
   docker push YOUR_DOCKERHUB_USERNAME/task-manager:latest
   ```

5. **Add GitHub Secrets:**
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password or access token

### Option 2: AWS ECR (Elastic Container Registry)

1. **Create ECR Repository:**
   ```bash
   aws ecr create-repository --repository-name task-manager --region us-east-1
   ```

2. **Login to ECR:**
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
   ```

3. **Tag and push:**
   ```bash
   docker tag task-manager:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/task-manager:latest
   docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/task-manager:latest
   ```

## EC2 Docker Setup

### Install Docker on EC2

SSH into your EC2 instance and run:

```bash
# Update packages
sudo apt update

# Install Docker
sudo apt install -y docker.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group (to run docker without sudo)
sudo usermod -aG docker ubuntu

# Log out and log back in for group changes to take effect
exit
# SSH back in

# Verify Docker installation
docker --version
docker run hello-world
```

### Create systemd Service for Auto-Restart

Create a systemd service file:

```bash
sudo tee /etc/systemd/system/task-manager.service << 'EOF'
[Unit]
Description=Task Manager Docker Container
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu
ExecStartPre=-/usr/bin/docker stop task-manager
ExecStartPre=-/usr/bin/docker rm task-manager
ExecStartPre=/usr/bin/docker pull YOUR_DOCKERHUB_USERNAME/task-manager:latest
ExecStart=/usr/bin/docker run -d \
  --name task-manager \
  -p 80:80 \
  --restart unless-stopped \
  YOUR_DOCKERHUB_USERNAME/task-manager:latest
ExecStop=/usr/bin/docker stop task-manager

[Install]
WantedBy=multi-user.target
EOF
```

**Important:** Replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username.

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable task-manager
sudo systemctl start task-manager
```

### Service Management Commands

```bash
# Check service status
sudo systemctl status task-manager

# View service logs
sudo journalctl -u task-manager -f

# Restart service
sudo systemctl restart task-manager

# Stop service
sudo systemctl stop task-manager

# Start service
sudo systemctl start task-manager
```

## Phase 4: Full CI/CD Pipeline with Docker

The updated GitHub Actions workflow will:

1. Build Docker image
2. Push to Docker Hub/ECR
3. SSH into EC2
4. Pull latest image
5. Restart container
6. Verify deployment

### Updated GitHub Secrets Required

**For Docker Hub:**
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub password/token
- `EC2_HOST`: EC2 public IP
- `EC2_USERNAME`: `ubuntu`
- `EC2_SSH_KEY`: EC2 private key

**For AWS ECR:**
- `AWS_REGION`: e.g., `us-east-1`
- `AWS_ACCESS_KEY_ID`: IAM user access key
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key
- `ECR_REPOSITORY`: ECR repository URI
- `EC2_HOST`: EC2 public IP
- `EC2_USERNAME`: `ubuntu`
- `EC2_SSH_KEY`: EC2 private key

### Deployment Process

1. **Push code to GitHub:**
   ```bash
   git add .
   git commit -m "Update application"
   git push
   ```

2. **GitHub Actions automatically:**
   - Builds Docker image
   - Pushes to registry
   - Deploys to EC2

3. **Verify deployment:**
   ```bash
   # Check if container is running
   ssh -i your-key.pem ubuntu@YOUR_EC2_IP "docker ps"
   
   # View container logs
   ssh -i your-key.pem ubuntu@YOUR_EC2_IP "docker logs task-manager"
   ```

## Troubleshooting

### Image build fails
```bash
# Check Docker daemon is running
docker info

# Clean build cache
docker builder prune -a

# Build with verbose output
docker build --progress=plain -t task-manager:latest .
```

### Container exits immediately
```bash
# Check container logs
docker logs task-manager

# Run interactively for debugging
docker run -it --rm task-manager:latest sh
```

### Can't push to Docker Hub
```bash
# Re-login
docker logout
docker login

# Verify image name format
# Should be: username/repository:tag
docker tag task-manager:latest YOUR_USERNAME/task-manager:latest
```

### EC2 container not updating
```bash
# Manually pull and restart
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

docker stop task-manager
docker rm task-manager
docker pull YOUR_USERNAME/task-manager:latest
docker run -d --name task-manager -p 80:80 YOUR_USERNAME/task-manager:latest
```

### Port already in use
```bash
# Stop Nginx if it's running
sudo systemctl stop nginx
sudo systemctl disable nginx

# Or use a different port
docker run -d -p 8080:80 --name task-manager task-manager:latest
```

## Image Optimization

Current image size optimizations:
- ✅ Multi-stage build (only final artifacts in production image)
- ✅ Alpine-based images (smaller base images)
- ✅ `.dockerignore` to exclude unnecessary files
- ✅ Nginx for efficient static file serving

Additional optimizations:
```dockerfile
# Use nginx-unprivileged for better security
FROM nginxinc/nginx-unprivileged:alpine

# Or use a smaller base image
FROM busybox:latest
```

## Best Practices

1. **Always tag images with version numbers:**
   ```bash
   docker build -t task-manager:v1.0.0 .
   docker build -t task-manager:latest .
   ```

2. **Use health checks** (already included in Dockerfile)

3. **Set resource limits:**
   ```bash
   docker run -d \
     --memory="256m" \
     --cpus="0.5" \
     -p 3000:80 \
     task-manager:latest
   ```

4. **Regular cleanup:**
   ```bash
   # Remove unused images
   docker image prune -a
   
   # Remove unused containers
   docker container prune
   ```

5. **Monitor container:**
   ```bash
   # View resource usage
   docker stats task-manager
   ```

## Next Steps

After Docker deployment is working:
1. ✅ Implement blue-green deployment
2. ✅ Add container monitoring
3. ✅ Set up automatic rollback on failure
4. ✅ Implement environment-specific configurations
5. ✅ Add SSL/HTTPS support
6. ✅ Set up container orchestration (Docker Swarm or Kubernetes)

