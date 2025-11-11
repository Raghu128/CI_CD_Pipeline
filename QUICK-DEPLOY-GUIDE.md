# Quick Deploy Guide (No Docker Hub Required)

This guide shows you how to deploy your app to AWS EC2 with automatic Docker builds on the server itself. **No Docker Hub account needed!**

---

## ✅ What You Need

- AWS account ($100 credits you have)
- GitHub account
- SSH key pair (you'll get this when creating EC2)
- 30 minutes of time

---

## 🚀 Step-by-Step Deployment

### **Step 1: Push Code to GitHub (5 minutes)**

```bash
# 1. Create a new repository on GitHub
#    Go to: https://github.com/new
#    Name: task-manager-cicd (or any name)
#    Don't initialize with README

# 2. Push your code
cd /Users/raghukumar/Desktop/CI_CD_Pipleine

git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

✅ **Your code is now on GitHub!**

---

### **Step 2: Launch AWS EC2 Instance (5 minutes)**

1. **Go to AWS Console**: https://console.aws.amazon.com/ec2/

2. **Click "Launch Instance"**

3. **Configure:**
   - **Name**: `task-manager-server`
   - **AMI**: Ubuntu Server 22.04 LTS (Free tier)
   - **Instance Type**: t2.micro (Free tier)
   - **Key Pair**: Create new → Download `.pem` file → **SAVE IT SECURELY!**
   - **Security Group**: 
     - ✅ Allow SSH (port 22) from Anywhere
     - ✅ Allow HTTP (port 80) from Anywhere

4. **Click "Launch Instance"**

5. **Wait 1 minute**, then note your **Public IPv4 address**

Example: `54.123.45.67` ← This is your EC2_HOST

---

### **Step 3: Setup EC2 with Docker (10 minutes)**

```bash
# 1. Connect to your EC2
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

```bash
# 2. Run these commands on EC2:

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker ubuntu

# Verify Docker works
docker --version
```

```bash
# 3. Log out and back in for group changes
exit
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Test Docker (should work without sudo now)
docker run hello-world
```

✅ **EC2 is ready!**

---

### **Step 4: Configure GitHub Secrets (3 minutes)**

1. **Go to your GitHub repository**
2. **Click**: Settings → Secrets and variables → Actions → New repository secret

**Add these 3 secrets:**

#### Secret 1: EC2_HOST
```
Name: EC2_HOST
Value: YOUR_EC2_PUBLIC_IP
Example: 54.123.45.67
```

#### Secret 2: EC2_USERNAME
```
Name: EC2_USERNAME
Value: ubuntu
```

#### Secret 3: EC2_SSH_KEY
```
Name: EC2_SSH_KEY
Value: (paste entire .pem file content)
```

**To get .pem content:**
```bash
cat your-key.pem
# Copy ALL output including BEGIN/END lines
```

✅ **Secrets configured!**

---

### **Step 5: Deploy! (2 minutes)**

```bash
# Make any small change to trigger deployment
cd /Users/raghukumar/Desktop/CI_CD_Pipleine
echo "# Deployed!" >> README.md

git add .
git commit -m "First deployment"
git push
```

**Watch the magic happen:**

1. Go to GitHub → Your Repo → **Actions** tab
2. Click on the running workflow
3. Watch it:
   - ✅ Connect to EC2
   - ✅ Clone/pull your code
   - ✅ Build Docker image on EC2
   - ✅ Start container
   - ✅ Verify it's running

**When complete (2-3 minutes):**

🎉 **Visit: `http://YOUR_EC2_IP`**

**Your app is LIVE!** 🚀

---

## 📊 How It Works

```
You Push Code
    ↓
GitHub Actions Triggers
    ↓
SSH into EC2
    ↓
Pull Latest Code on EC2
    ↓
Build Docker Image on EC2
    ↓
Stop Old Container
    ↓
Start New Container
    ↓
✅ App Updated!
```

**Key Point**: Docker image is built **directly on EC2**, not pushed to any registry!

---

## 🔄 Updating Your App

Every time you push code, it auto-deploys:

```bash
# Make changes to your code
cd /Users/raghukumar/Desktop/CI_CD_Pipleine/Frontend/src

# Edit files...

# Commit and push
git add .
git commit -m "Updated feature"
git push

# Watch GitHub Actions deploy automatically!
```

---

## 🛠️ Useful Commands

### **Check Deployment Status**
```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Check if container is running
docker ps

# View container logs
docker logs -f task-manager

# Check app response
curl http://localhost
```

### **Manual Deployment (if needed)**
```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Go to project
cd YOUR_REPO_NAME/Frontend

# Pull latest
git pull

# Rebuild
docker stop task-manager
docker rm task-manager
docker build -t task-manager:latest .
docker run -d --name task-manager -p 80:80 --restart unless-stopped task-manager:latest
```

### **View GitHub Actions Logs**
```
GitHub → Your Repo → Actions → Click workflow run
```

---

## 🐛 Troubleshooting

### **GitHub Actions fails: "Permission denied"**
- Check EC2 security group allows SSH from anywhere (0.0.0.0/0)
- Verify `EC2_SSH_KEY` secret has complete .pem file content

### **Container not starting**
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
docker logs task-manager
```

### **App not loading in browser**
- Check EC2 security group allows HTTP (port 80)
- Verify container is running: `docker ps`
- Test on EC2: `curl http://localhost`

### **Build fails on EC2**
```bash
# SSH and check logs
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
cd YOUR_REPO_NAME/Frontend
docker build -t task-manager:latest .
# Read the error message
```

---

## 💰 Cost

**With AWS Free Tier:**
- EC2 t2.micro: **$0** (750 hours/month free)
- Data Transfer: **$0** (100 GB/month free)
- **Total: $0/month** ✅

**After Free Tier:**
- ~$8-10/month

**Tip**: Stop EC2 when not using it!

---

## 🎯 What You've Achieved

✅ Full CI/CD pipeline with GitHub Actions  
✅ Docker containerization  
✅ Automatic deployment to AWS EC2  
✅ Build happens on server (no registry needed)  
✅ Professional DevOps workflow  
✅ **Zero extra services or accounts!**

---

## 📚 Summary

| Action | Command |
|--------|---------|
| **Deploy** | `git push` |
| **Check status** | GitHub Actions tab |
| **View logs** | `docker logs -f task-manager` |
| **SSH to EC2** | `ssh -i key.pem ubuntu@YOUR_IP` |
| **Manual rebuild** | See "Manual Deployment" above |

---

## 🚀 Next Steps

Now that it's working:

1. **Customize your app** - Edit `Frontend/src/App.tsx`
2. **Add features** - More task categories, filters, etc.
3. **Test the pipeline** - Make changes and watch auto-deploy
4. **Add monitoring** - Set up CloudWatch alerts
5. **Get a domain** - Add custom domain + HTTPS

---

## 🎉 Congratulations!

You now have:
- ✅ A production app running on AWS
- ✅ Automatic deployments on every push
- ✅ Docker containerization
- ✅ Professional CI/CD experience

**This is real DevOps work!** Add it to your resume! 💼

---

*Questions? Check the main README.md or documentation files.*

**Happy deploying! 🚀**

