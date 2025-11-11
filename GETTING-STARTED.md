# Getting Started - Quick Guide

Welcome to your CI/CD Pipeline Learning Project! This guide will get you up and running quickly.

## What You Have

✅ A fully functional Task Management Dashboard (React + Tailwind CSS)
✅ Complete CI/CD pipeline configuration (GitHub Actions)
✅ Docker containerization setup
✅ EC2 deployment scripts and guides
✅ Comprehensive documentation

## Quick Start (5 Minutes to First Deployment)

### Step 1: Push to GitHub (2 minutes)

```bash
# Create a new repository on GitHub (https://github.com/new)
# Name it something like: task-manager-cicd
# Don't initialize with README

# Then run:
cd /Users/raghukumar/Desktop/CI_CD_Pipleine
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

Your code is now on GitHub! 🎉

### Step 2: Launch EC2 Instance (3 minutes)

1. Go to [AWS EC2 Console](https://console.aws.amazon.com/ec2/)
2. Click **"Launch Instance"**
3. Quick config:
   - Name: `task-manager`
   - AMI: **Ubuntu Server 22.04 LTS**
   - Instance type: **t2.micro** (Free tier)
   - Key pair: Create new or select existing → **Download .pem file**
   - Security groups: ✅ SSH (22), ✅ HTTP (80)
4. Click **"Launch Instance"**
5. Wait 30 seconds, then note your **Public IPv4 address**

### Step 3: Setup EC2 (2 minutes)

```bash
# Connect to your EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Copy and paste this command to download and run the setup script:
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/scripts/setup-ec2.sh -o setup.sh && chmod +x setup.sh && ./setup.sh
```

Wait for setup to complete... ✅

### Step 4: Configure GitHub Secrets (2 minutes)

Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

Click **"New repository secret"** and add these three:

1. **EC2_HOST**
   - Value: Your EC2 IP (e.g., `54.123.45.67`)

2. **EC2_USERNAME**
   - Value: `ubuntu`

3. **EC2_SSH_KEY**
   - Value: Paste entire content of your .pem file:
   ```bash
   cat your-key.pem
   # Copy all output including BEGIN/END lines
   ```

### Step 5: Deploy! (1 minute)

```bash
# Make a test change
echo "# CI/CD Test" >> README.md
git add .
git commit -m "Test deployment"
git push
```

Go to your GitHub repository → **Actions** tab

Watch the magic happen! ✨

When complete (2-3 minutes), visit: `http://YOUR_EC2_IP`

**🎉 Congratulations! Your app is live!**

---

## What Just Happened?

1. ✅ You pushed code to GitHub
2. ✅ GitHub Actions automatically detected the push
3. ✅ It built your React application
4. ✅ Deployed files to your EC2 server
5. ✅ Your app is now live on the internet!

---

## Next Steps

Now that basic deployment works, you can:

### Option A: Add Docker (Recommended)

Follow: `scripts/DOCKER-GUIDE.md`

This adds:
- ✅ Containerization
- ✅ Easier rollback
- ✅ Better deployment consistency
- ✅ Production-ready setup

**Time:** 15-20 minutes

### Option B: Customize Your App

Edit `Frontend/src/App.tsx` and make it yours:
- Add new features
- Change colors and styling
- Add more task categories
- Integrate with an API

Every time you push, it auto-deploys! 🚀

### Option C: Learn More

Explore the documentation:
- `README.md` - Project overview
- `SETUP-CHECKLIST.md` - Detailed checklist
- `scripts/EC2-SETUP-GUIDE.md` - EC2 deep dive
- `scripts/DOCKER-GUIDE.md` - Docker deployment
- `scripts/DEPLOYMENT-WORKFLOW.md` - Complete workflow guide

---

## Common Issues & Solutions

### "Permission denied" when connecting to EC2
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

### GitHub Actions failing
1. Check all 3 secrets are added correctly
2. Verify no extra spaces in secret values
3. Ensure EC2 security group allows SSH from anywhere (0.0.0.0/0)

### App not loading at EC2 IP
1. Check security group allows HTTP (port 80)
2. Verify deployment completed successfully in GitHub Actions
3. Check Nginx: `ssh -i your-key.pem ubuntu@YOUR_EC2_IP "sudo systemctl status nginx"`

### Still stuck?
Check the troubleshooting section in:
- `SETUP-CHECKLIST.md`
- `scripts/EC2-SETUP-GUIDE.md`

---

## Your Learning Path

```
[✅ You are here]
Phase 1: React App Built
    ↓
Phase 2: Basic CI/CD → Deploy on every push
    ↓
Phase 3: Add Docker → Containerize app
    ↓
Phase 4: Docker CI/CD → Full production pipeline
    ↓
[🎓 Beyond]
- Add tests
- Multiple environments (staging/production)
- Database integration
- Advanced monitoring
- Custom domain + HTTPS
- Container orchestration (Kubernetes)
```

---

## Quick Commands Reference

### Development
```bash
cd Frontend
npm install          # Install dependencies
npm run dev          # Run development server
npm run build        # Build for production
```

### Deployment
```bash
git add .
git commit -m "Your changes"
git push             # Triggers automatic deployment
```

### Check Deployment
```bash
# View GitHub Actions
https://github.com/YOUR_USERNAME/YOUR_REPO/actions

# Check EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
sudo systemctl status nginx
sudo tail -f /var/log/nginx/access.log
```

---

## Project Structure

```
CI_CD_Pipleine/
├── Frontend/                    # React application
│   ├── src/                    # Source code
│   │   ├── components/         # React components
│   │   ├── App.tsx            # Main app
│   │   └── index.css          # Styles
│   ├── Dockerfile             # Docker configuration
│   └── package.json           # Dependencies
├── .github/
│   └── workflows/
│       ├── deploy.yml         # Basic deployment
│       └── deploy-docker.yml  # Docker deployment
├── scripts/                    # Setup scripts and guides
├── README.md                   # Main documentation
├── SETUP-CHECKLIST.md         # Detailed checklist
└── GETTING-STARTED.md         # This file
```

---

## Tips for Success

1. **Start Simple:** Get Phase 2 working before moving to Docker
2. **Read Error Messages:** GitHub Actions logs are your friend
3. **Test Locally First:** Run `npm run build` before pushing
4. **Keep Costs Low:** Stop EC2 when not using it
5. **Document Changes:** Good commit messages help debugging
6. **Backup Important:** Save your .pem file securely!

---

## Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
- [React Documentation](https://react.dev/)
- [Tailwind CSS](https://tailwindcss.com/)

---

## Need Help?

1. Check the documentation files (listed above)
2. Review GitHub Actions logs for errors
3. Check AWS EC2 console for instance status
4. Test components individually (build, deploy, etc.)

---

## Celebrate Your Success! 🎉

You've just:
- ✅ Built a modern React application
- ✅ Set up AWS infrastructure
- ✅ Created a CI/CD pipeline
- ✅ Deployed to production

This is real DevOps experience that companies value!

**Now go break things, fix them, and learn! 🚀**

---

*Last updated: 2025*
*Project: CI/CD Pipeline Learning*

