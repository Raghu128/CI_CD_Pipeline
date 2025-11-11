#!/bin/bash

# Docker Setup Script for EC2
# Run this script on your EC2 instance to install Docker and set up the container service

set -e

echo "=========================================="
echo "Task Manager - Docker Setup for EC2"
echo "=========================================="
echo ""

# Check if running as ubuntu user
if [ "$(whoami)" != "ubuntu" ]; then
    echo "⚠️  This script should be run as the ubuntu user"
    exit 1
fi

# Prompt for Docker Hub username
echo "Enter your Docker Hub username (or leave empty for ECR):"
read -r DOCKER_USERNAME

if [ -z "$DOCKER_USERNAME" ]; then
    echo "ℹ️  Skipping Docker Hub setup. You'll need to configure ECR separately."
    USE_DOCKER_HUB=false
else
    USE_DOCKER_HUB=true
    echo "Using Docker Hub with username: $DOCKER_USERNAME"
fi

echo ""
echo "📦 Installing Docker..."

# Update package index
sudo apt update

# Install Docker
sudo apt install -y docker.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

echo ""
echo "✅ Docker installed successfully!"
echo "ℹ️  You'll need to log out and log back in for group changes to take effect."
echo ""

# Stop and disable Nginx if it's running (to free up port 80)
if systemctl is-active --quiet nginx; then
    echo "🛑 Stopping Nginx to free up port 80..."
    sudo systemctl stop nginx
    sudo systemctl disable nginx
    echo "✅ Nginx stopped and disabled"
fi

# Create systemd service file
if [ "$USE_DOCKER_HUB" = true ]; then
    echo ""
    echo "📝 Creating systemd service for auto-restart..."
    
    sudo tee /etc/systemd/system/task-manager.service > /dev/null << EOF
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
ExecStartPre=/usr/bin/docker pull ${DOCKER_USERNAME}/task-manager:latest
ExecStart=/usr/bin/docker run -d \\
  --name task-manager \\
  -p 80:80 \\
  --restart unless-stopped \\
  ${DOCKER_USERNAME}/task-manager:latest
ExecStop=/usr/bin/docker stop task-manager

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable task-manager
    
    echo "✅ Systemd service created and enabled"
    echo ""
    echo "Service will automatically:"
    echo "  - Start on boot"
    echo "  - Pull latest image"
    echo "  - Restart container"
fi

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "=========================================="
echo "✅ Docker Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""

if [ "$USE_DOCKER_HUB" = true ]; then
    echo "1. Log out and log back in: exit"
    echo "2. Test Docker: docker run hello-world"
    echo "3. Login to Docker Hub: docker login"
    echo "4. Add GitHub Secrets:"
    echo "   - DOCKER_USERNAME='${DOCKER_USERNAME}'"
    echo "   - DOCKER_PASSWORD='your_docker_hub_password'"
    echo "   - EC2_HOST='${PUBLIC_IP}'"
    echo "   - EC2_USERNAME='ubuntu'"
    echo "   - EC2_SSH_KEY='your_private_key'"
    echo ""
    echo "5. To start the container service:"
    echo "   sudo systemctl start task-manager"
    echo ""
    echo "6. To check service status:"
    echo "   sudo systemctl status task-manager"
else
    echo "1. Log out and log back in: exit"
    echo "2. Test Docker: docker run hello-world"
    echo "3. Configure AWS ECR access"
    echo "4. Update GitHub Actions workflow with ECR settings"
fi

echo ""
echo "Your EC2 public IP: ${PUBLIC_IP}"
echo "Container will be accessible at: http://${PUBLIC_IP}"
echo ""

# Create a helpful script for manual deployment testing
cat > /home/ubuntu/deploy-manual.sh << 'DEPLOYEOF'
#!/bin/bash
# Manual deployment script for testing

set -e

DOCKER_USERNAME="${1:-YOUR_DOCKERHUB_USERNAME}"

echo "Pulling latest image..."
docker pull ${DOCKER_USERNAME}/task-manager:latest

echo "Stopping old container..."
docker stop task-manager 2>/dev/null || true
docker rm task-manager 2>/dev/null || true

echo "Starting new container..."
docker run -d \
  --name task-manager \
  -p 80:80 \
  --restart unless-stopped \
  ${DOCKER_USERNAME}/task-manager:latest

echo "Checking container status..."
docker ps | grep task-manager

echo ""
echo "✅ Deployment complete!"
echo "View logs: docker logs -f task-manager"
DEPLOYEOF

chmod +x /home/ubuntu/deploy-manual.sh

if [ "$USE_DOCKER_HUB" = true ]; then
    # Update the script with actual username
    sed -i "s/YOUR_DOCKERHUB_USERNAME/${DOCKER_USERNAME}/" /home/ubuntu/deploy-manual.sh
    echo "Created manual deployment script: ~/deploy-manual.sh"
fi

echo ""

