# Complete Deployment Workflow Guide

This guide covers the complete CI/CD pipeline implementation from development to production deployment using Docker.

## Overview

The project has two deployment approaches:
1. **Phase 2:** Static file deployment to EC2 with Nginx
2. **Phase 4:** Docker container deployment to EC2

## Quick Start Checklist

### Prerequisites
- [ ] AWS account with EC2 access
- [ ] GitHub account and repository
- [ ] Docker Hub account (or AWS ECR)
- [ ] Git installed locally
- [ ] SSH key pair for EC2

### Phase 1: Development (✅ Completed)
- [x] React Task Manager application built
- [x] Tailwind CSS configured
- [x] Local development working
- [x] Production build tested

### Phase 2: Basic CI/CD Setup

#### Step 1: Create GitHub Repository

```bash
# Create repository on GitHub first, then:
cd /Users/raghukumar/Desktop/CI_CD_Pipleine
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

#### Step 2: Launch EC2 Instance

1. Go to AWS EC2 Console
2. Click "Launch Instance"
3. Configure:
   - **Name:** task-manager-server
   - **AMI:** Ubuntu Server 22.04 LTS
   - **Instance Type:** t2.micro
   - **Key Pair:** Create new or select existing
   - **Security Groups:** Allow SSH (22) and HTTP (80)
4. Launch and wait for "Running" state

#### Step 3: Setup EC2 with Nginx

```bash
# Connect to EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Download and run setup script
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/scripts/setup-ec2.sh
chmod +x setup-ec2.sh
./setup-ec2.sh
```

Or manually copy the script from `scripts/setup-ec2.sh` and run it.

#### Step 4: Configure GitHub Secrets

Go to: **GitHub Repository → Settings → Secrets and variables → Actions → New repository secret**

Add these secrets:
```
EC2_HOST=YOUR_EC2_PUBLIC_IP
EC2_USERNAME=ubuntu
EC2_SSH_KEY=<paste entire .pem file content>
```

#### Step 5: Test Basic Deployment

```bash
# Make a small change
echo "Test" >> README.md
git add .
git commit -m "Test CI/CD pipeline"
git push
```

Watch GitHub Actions tab - deployment should complete and app should be live at `http://YOUR_EC2_IP`

### Phase 3: Dockerization

#### Step 1: Install Docker Locally (Optional)

**On macOS:**
```bash
brew install --cask docker
# Open Docker Desktop application
```

**On Linux:**
```bash
sudo apt install docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### Step 2: Test Docker Build Locally (Optional)

```bash
cd Frontend
docker build -t task-manager:latest .
docker run -d -p 3000:80 --name test-app task-manager:latest

# Visit http://localhost:3000
# Stop when done
docker stop test-app
docker rm test-app
```

#### Step 3: Set Up Docker Hub

1. Create account at https://hub.docker.com
2. Create repository named "task-manager"
3. Create access token:
   - Account Settings → Security → New Access Token
   - Save the token securely

#### Step 4: Add Docker Hub Secrets to GitHub

```
DOCKER_USERNAME=your_dockerhub_username
DOCKER_PASSWORD=your_dockerhub_token_or_password
```

### Phase 4: Docker Deployment Pipeline

#### Step 1: Prepare EC2 for Docker

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Download and run Docker setup script
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/scripts/setup-docker-ec2.sh
chmod +x setup-docker-ec2.sh
./setup-docker-ec2.sh

# When prompted, enter your Docker Hub username
# Log out and log back in
exit
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Test Docker
docker run hello-world

# Login to Docker Hub
docker login
```

#### Step 2: Switch to Docker Workflow

**Option A: Disable old workflow and use Docker workflow**

Rename the workflows:
```bash
git mv .github/workflows/deploy.yml .github/workflows/deploy-static.yml.disabled
git mv .github/workflows/deploy-docker.yml .github/workflows/deploy.yml
git add .
git commit -m "Switch to Docker deployment"
git push
```

**Option B: Use both workflows selectively**

Keep both workflows, but rename branches or add conditions to control when each runs.

#### Step 3: Test Docker Deployment

```bash
# Make a change
# The workflow will:
# 1. Build Docker image
# 2. Push to Docker Hub
# 3. Deploy to EC2
# 4. Verify health

git add .
git commit -m "Test Docker deployment"
git push
```

Watch GitHub Actions - you should see:
- ✅ Docker image built
- ✅ Pushed to Docker Hub
- ✅ Deployed to EC2
- ✅ Health check passed

Visit `http://YOUR_EC2_IP` to see your app running in Docker!

## Workflow Comparison

### Static Deployment (Phase 2)
```
Code Push → Build React → Copy files via SSH → Reload Nginx
```

**Pros:**
- Simpler setup
- Faster deployment
- Lower resource usage

**Cons:**
- Less portable
- Manual server configuration
- Harder to rollback

### Docker Deployment (Phase 4)
```
Code Push → Build Docker Image → Push to Registry → Pull on EC2 → Run Container
```

**Pros:**
- Consistent environment
- Easy rollback
- Portable across servers
- Easier scaling

**Cons:**
- Slightly more complex
- Requires Docker knowledge
- Small overhead

## Common Tasks

### View Deployment Logs

**GitHub Actions:**
```
GitHub Repository → Actions → Select workflow run
```

**EC2 Static Deployment:**
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

**EC2 Docker Deployment:**
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
docker logs -f task-manager
sudo journalctl -u task-manager -f  # If using systemd service
```

### Manual Deployment

**Static:**
```bash
cd Frontend
npm run build
scp -i your-key.pem -r dist/* ubuntu@YOUR_EC2_IP:/var/www/html/
```

**Docker:**
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
~/deploy-manual.sh YOUR_DOCKERHUB_USERNAME
```

### Rollback to Previous Version

**Static Deployment:**
```bash
# Revert code
git revert HEAD
git push
```

**Docker Deployment:**
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# View available images
docker images task-manager

# Stop current container
docker stop task-manager
docker rm task-manager

# Run previous image (replace IMAGE_ID)
docker run -d --name task-manager -p 80:80 --restart unless-stopped IMAGE_ID
```

### Update Application

```bash
# Make changes to code
git add .
git commit -m "Your changes"
git push

# GitHub Actions automatically deploys
```

### Stop Deployment

**Disable GitHub Actions:**
```
Repository → Settings → Actions → General → Disable Actions
```

**Or comment out workflow trigger:**
```yaml
# on:
#   push:
#     branches:
#       - main
```

## Monitoring and Maintenance

### Check Application Status

```bash
# Using curl
curl -I http://YOUR_EC2_IP

# Health check endpoint (Docker only)
curl http://YOUR_EC2_IP/health
```

### Monitor Resource Usage

```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# System resources
top
htop  # Install with: sudo apt install htop

# Docker resources (if using Docker)
docker stats task-manager

# Disk space
df -h
```

### Clean Up

**Remove old Docker images:**
```bash
docker image prune -a
```

**Remove old containers:**
```bash
docker container prune
```

**Free up disk space:**
```bash
sudo apt autoremove
sudo apt clean
```

## Troubleshooting

### Deployment Fails on GitHub Actions

1. **Check GitHub Actions logs:**
   - Go to Actions tab
   - Click on failed run
   - Expand each step to see errors

2. **Common issues:**
   - Missing secrets
   - Wrong SSH key format
   - EC2 security group blocking SSH
   - Docker Hub login failed

### Application Not Loading

1. **Check if service is running:**
   ```bash
   # Static
   sudo systemctl status nginx
   
   # Docker
   docker ps
   ```

2. **Check firewall:**
   ```bash
   sudo ufw status
   # If active, allow HTTP
   sudo ufw allow 80/tcp
   ```

3. **Check application logs** (see above)

### EC2 Connection Refused

- Verify security group allows your IP
- Check EC2 is in "Running" state
- Verify SSH key permissions: `chmod 400 your-key.pem`
- Try using EC2 Instance Connect from AWS Console

## Cost Optimization

- **Stop EC2 when not needed:** Instance State → Stop
- **Use t2.micro:** Stays in free tier (750 hours/month)
- **Monitor billing:** Set up AWS billing alerts
- **Clean up regularly:** Remove unused Docker images and logs

## Next Steps

Once you have Docker deployment working:

1. **Add environment variables** for configuration
2. **Set up staging environment** (separate EC2)
3. **Implement blue-green deployment**
4. **Add monitoring** (CloudWatch, Datadog)
5. **Set up alerts** for deployment failures
6. **Add SSL/HTTPS** with Let's Encrypt
7. **Use load balancer** for multiple instances
8. **Explore container orchestration** (ECS, Kubernetes)

## Quick Reference Commands

```bash
# Connect to EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# View running containers
docker ps

# View container logs
docker logs -f task-manager

# Restart container
docker restart task-manager

# Check Nginx (static deployment)
sudo systemctl status nginx
sudo nginx -t

# View GitHub Actions locally (optional)
# Install: brew install act
act push

# Build and test Docker locally
docker build -t task-manager:latest Frontend/
docker run -p 3000:80 task-manager:latest
```

## Support and Resources

- **Docker Documentation:** https://docs.docker.com/
- **GitHub Actions Documentation:** https://docs.github.com/actions
- **AWS EC2 Documentation:** https://docs.aws.amazon.com/ec2/
- **Nginx Documentation:** https://nginx.org/en/docs/

## Conclusion

You now have a complete CI/CD pipeline! Every time you push code:
1. ✅ Tests can be added (optional)
2. ✅ Application builds automatically
3. ✅ Docker image created and pushed
4. ✅ Deployed to EC2
5. ✅ Health verified
6. ✅ Rollback on failure

Keep experimenting and improving your pipeline! 🚀

