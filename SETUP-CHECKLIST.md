# CI/CD Pipeline Setup Checklist

Use this checklist to track your progress through the complete CI/CD pipeline setup.

## Phase 1: Build React Application ✅

- [x] Initialize React project with Vite
- [x] Install Tailwind CSS
- [x] Create Task Management components
- [x] Implement CRUD operations
- [x] Add dark/light theme
- [x] Test local development (`npm run dev`)
- [x] Test production build (`npm run build`)

## Phase 2: Basic CI/CD with Static Deployment

### Local Setup
- [ ] Initialize Git repository
- [ ] Create GitHub repository
- [ ] Push code to GitHub
  ```bash
  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
  git push -u origin main
  ```

### AWS EC2 Setup
- [ ] Launch EC2 instance (t2.micro, Ubuntu 22.04)
- [ ] Configure security groups (SSH port 22, HTTP port 80)
- [ ] Save SSH key pair (.pem file)
- [ ] Note your EC2 public IP address: ________________

### EC2 Configuration
- [ ] Connect to EC2 via SSH
- [ ] Run `setup-ec2.sh` script
- [ ] Verify Nginx is running
- [ ] Test placeholder page at `http://YOUR_EC2_IP`

### GitHub Secrets Configuration
- [ ] Add `EC2_HOST` secret (your EC2 public IP)
- [ ] Add `EC2_USERNAME` secret (value: `ubuntu`)
- [ ] Add `EC2_SSH_KEY` secret (entire .pem file content)

### Test Deployment
- [ ] Make a test commit and push
- [ ] Watch GitHub Actions workflow run
- [ ] Verify deployment at `http://YOUR_EC2_IP`
- [ ] Check that app works correctly

**🎉 Milestone: Basic CI/CD Working!**

---

## Phase 3: Dockerization

### Docker Hub Setup
- [ ] Create Docker Hub account at https://hub.docker.com
- [ ] Create repository named "task-manager"
- [ ] Create access token (Account Settings → Security)
- [ ] Save your Docker Hub username: ________________

### Local Docker Testing (Optional)
- [ ] Install Docker Desktop or Docker Engine
- [ ] Test Docker build:
  ```bash
  cd Frontend
  docker build -t task-manager:latest .
  ```
- [ ] Test Docker run:
  ```bash
  docker run -d -p 3000:80 --name test task-manager:latest
  ```
- [ ] Visit `http://localhost:3000` to verify
- [ ] Clean up test container:
  ```bash
  docker stop test && docker rm test
  ```

### Docker Hub Integration
- [ ] Push test image to Docker Hub (optional):
  ```bash
  docker login
  docker tag task-manager:latest YOUR_USERNAME/task-manager:latest
  docker push YOUR_USERNAME/task-manager:latest
  ```
- [ ] Verify image on Docker Hub

**🎉 Milestone: Docker Image Working!**

---

## Phase 4: Full CI/CD with Docker Deployment

### GitHub Secrets for Docker
- [ ] Add `DOCKER_USERNAME` secret
- [ ] Add `DOCKER_PASSWORD` secret (Docker Hub token)
- [ ] Keep existing EC2 secrets

### EC2 Docker Setup
- [ ] SSH into EC2
- [ ] Run `setup-docker-ec2.sh` script
- [ ] Enter your Docker Hub username when prompted
- [ ] Log out and log back in
- [ ] Test Docker: `docker run hello-world`
- [ ] Login to Docker Hub: `docker login`

### Switch to Docker Workflow
- [ ] Commit and push docker-compose.yml and Dockerfile
- [ ] Enable `deploy-docker.yml` workflow
  ```bash
  git mv .github/workflows/deploy.yml .github/workflows/deploy-static.yml.disabled
  git mv .github/workflows/deploy-docker.yml .github/workflows/deploy.yml
  git add .
  git commit -m "Switch to Docker deployment"
  git push
  ```

### Test Docker Deployment
- [ ] Watch GitHub Actions workflow
- [ ] Verify Docker image built
- [ ] Verify image pushed to Docker Hub
- [ ] Verify deployment to EC2
- [ ] Check health endpoint: `curl http://YOUR_EC2_IP/health`
- [ ] Test application at `http://YOUR_EC2_IP`

### Verify Auto-Restart (Optional)
- [ ] Enable systemd service on EC2:
  ```bash
  sudo systemctl start task-manager
  sudo systemctl status task-manager
  ```
- [ ] Reboot EC2 and verify container auto-starts
- [ ] Check logs: `docker logs -f task-manager`

**🎉 Milestone: Complete CI/CD Pipeline Working!**

---

## Additional Enhancements (Optional)

### Testing and Quality
- [ ] Add unit tests for React components
- [ ] Add GitHub Actions test job
- [ ] Add linting checks
- [ ] Add code coverage reporting

### Security
- [ ] Set up HTTPS with Let's Encrypt
- [ ] Add custom domain name
- [ ] Implement security headers
- [ ] Use AWS IAM roles instead of keys
- [ ] Scan Docker images for vulnerabilities

### Monitoring
- [ ] Set up CloudWatch monitoring
- [ ] Add application performance monitoring (APM)
- [ ] Set up error tracking (Sentry, etc.)
- [ ] Create CloudWatch alarms
- [ ] Set up uptime monitoring

### Advanced Deployment
- [ ] Create staging environment
- [ ] Implement blue-green deployment
- [ ] Add deployment approvals
- [ ] Set up automatic rollback
- [ ] Use AWS ECS/Fargate instead of EC2
- [ ] Implement Kubernetes deployment

### CI/CD Improvements
- [ ] Add branch protection rules
- [ ] Require PR reviews
- [ ] Add automated dependency updates (Dependabot)
- [ ] Implement semantic versioning
- [ ] Add changelog generation

---

## Troubleshooting Checklist

If something doesn't work, check:

### GitHub Actions Failing
- [ ] All secrets are correctly set
- [ ] Secret names match workflow file
- [ ] No extra spaces in secret values
- [ ] SSH key is complete (including BEGIN/END lines)
- [ ] EC2 instance is running

### Can't Connect to EC2
- [ ] EC2 instance is running
- [ ] Security group allows SSH (port 22) from your IP
- [ ] SSH key file has correct permissions: `chmod 400 key.pem`
- [ ] Using correct username: `ubuntu` for Ubuntu AMI

### Application Not Loading
- [ ] EC2 security group allows HTTP (port 80)
- [ ] Nginx is running: `sudo systemctl status nginx`
- [ ] Files are in correct directory: `ls -la /var/www/html`
- [ ] Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`

### Docker Container Not Running
- [ ] Docker service is running: `sudo systemctl status docker`
- [ ] Container is running: `docker ps`
- [ ] Check container logs: `docker logs task-manager`
- [ ] Port 80 is not used by Nginx (stop Nginx if needed)
- [ ] Image was pulled successfully: `docker images`

### Deployment Doesn't Update
- [ ] Check GitHub Actions completed successfully
- [ ] On EC2, verify latest image was pulled: `docker images`
- [ ] Clear browser cache
- [ ] Check container was restarted: `docker ps` (check CREATED time)

---

## Important Commands Reference

### Git Commands
```bash
git status                           # Check status
git add .                            # Stage all changes
git commit -m "message"              # Commit with message
git push                             # Push to GitHub
git log --oneline                    # View commit history
```

### AWS EC2 Commands
```bash
ssh -i key.pem ubuntu@IP             # Connect to EC2
sudo systemctl status nginx          # Check Nginx
sudo systemctl reload nginx          # Reload Nginx
sudo tail -f /var/log/nginx/error.log # View logs
df -h                                # Check disk space
```

### Docker Commands
```bash
docker ps                            # List running containers
docker ps -a                         # List all containers
docker images                        # List images
docker logs -f task-manager          # View container logs
docker stop task-manager             # Stop container
docker start task-manager            # Start container
docker restart task-manager          # Restart container
docker exec -it task-manager sh      # Enter container
docker system prune -a               # Clean up everything
```

### Debugging Commands
```bash
curl -I http://YOUR_EC2_IP           # Test HTTP response
curl http://YOUR_EC2_IP/health       # Test health endpoint
wget http://YOUR_EC2_IP              # Download page
netstat -tlnp | grep :80             # Check what's on port 80
docker inspect task-manager          # Inspect container
```

---

## Success Criteria

Your CI/CD pipeline is working correctly when:

✅ **Phase 2 Success:**
- Pushing code to GitHub triggers automatic deployment
- Changes appear on your EC2 instance within 2-3 minutes
- Application is accessible at `http://YOUR_EC2_IP`
- All features work correctly

✅ **Phase 4 Success:**
- Docker image builds automatically on push
- Image appears on Docker Hub
- Container deploys to EC2 automatically
- Application accessible at `http://YOUR_EC2_IP`
- Health check endpoint responds
- Container auto-restarts after server reboot

---

## Notes

- **EC2 Public IP:** ________________
- **Docker Hub Username:** ________________
- **GitHub Repository:** ________________
- **Deployment Date:** ________________

## Resources

- Project Documentation: `README.md`
- EC2 Setup Guide: `scripts/EC2-SETUP-GUIDE.md`
- Docker Guide: `scripts/DOCKER-GUIDE.md`
- Deployment Workflow: `scripts/DEPLOYMENT-WORKFLOW.md`

---

**Good luck with your CI/CD learning journey! 🚀**

