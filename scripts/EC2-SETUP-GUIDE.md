# EC2 Setup Guide for Task Manager Deployment

This guide walks you through setting up an AWS EC2 instance for deploying the Task Manager application.

## Step 1: Launch EC2 Instance

1. **Log in to AWS Console** and navigate to EC2

2. **Click "Launch Instance"**

3. **Configure Instance:**
   - **Name:** task-manager-server (or any name you prefer)
   - **AMI:** Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance Type:** t2.micro (Free tier eligible)
   - **Key Pair:** 
     - Create a new key pair or use existing
     - **Important:** Download and save the `.pem` file securely
     - You'll need this for SSH access and GitHub Actions
   
4. **Network Settings:**
   - ✅ Allow SSH traffic from: Anywhere (0.0.0.0/0) or Your IP
   - ✅ Allow HTTP traffic from: Anywhere (0.0.0.0/0)
   
5. **Storage:** 8 GB gp3 (default is fine)

6. **Click "Launch Instance"**

7. **Wait for instance to be in "Running" state**

## Step 2: Connect to EC2 Instance

### Option A: Using AWS Console (Easiest)

1. Select your instance in EC2 dashboard
2. Click "Connect" button
3. Go to "EC2 Instance Connect" tab
4. Click "Connect"

### Option B: Using Terminal/SSH

```bash
chmod 400 your-key-pair.pem
ssh -i your-key-pair.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

Replace `YOUR_EC2_PUBLIC_IP` with the public IP shown in EC2 dashboard.

## Step 3: Run Setup Script

Once connected to your EC2 instance:

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/scripts/setup-ec2.sh

# Or copy-paste the script content into a new file:
nano setup-ec2.sh
# Paste the content, then press Ctrl+X, Y, Enter

# Make it executable
chmod +x setup-ec2.sh

# Run the script
./setup-ec2.sh
```

The script will:
- ✅ Update system packages
- ✅ Install and configure Nginx
- ✅ Set up deployment directory
- ✅ Create a placeholder page
- ✅ Display your public IP

## Step 4: Verify Setup

After the script completes, open your browser and visit:
```
http://YOUR_EC2_PUBLIC_IP
```

You should see a "EC2 Instance Ready!" page.

## Step 5: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings → Secrets and variables → Actions**
3. Click **"New repository secret"**
4. Add the following secrets:

### EC2_HOST
- **Name:** `EC2_HOST`
- **Value:** Your EC2 public IP address (e.g., `54.123.45.67`)

### EC2_USERNAME
- **Name:** `EC2_USERNAME`
- **Value:** `ubuntu`

### EC2_SSH_KEY
- **Name:** `EC2_SSH_KEY`
- **Value:** Your private key content (`.pem` file)

To get your private key content:
```bash
cat your-key-pair.pem
```

Copy the entire output including:
```
-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----
```

**⚠️ Important:** Keep your private key secure! Never commit it to the repository.

## Step 6: Test Deployment

1. Make a small change to your code (e.g., update a text in `App.tsx`)
2. Commit and push to the `main` branch:
   ```bash
   git add .
   git commit -m "Test deployment"
   git push
   ```
3. Go to GitHub repository → Actions tab
4. Watch the deployment workflow run
5. Once complete, visit `http://YOUR_EC2_PUBLIC_IP` to see your deployed app!

## Troubleshooting

### Can't connect to EC2 via SSH
- Check security group allows SSH (port 22) from your IP
- Verify you're using the correct key pair
- Ensure key file has correct permissions: `chmod 400 your-key.pem`

### Nginx not working
```bash
# Check Nginx status
sudo systemctl status nginx

# View error logs
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx
```

### GitHub Actions deployment fails
- Verify all three secrets are correctly set
- Check EC2 security group allows SSH from GitHub Actions IPs (or allow 0.0.0.0/0)
- Check GitHub Actions logs for specific error messages

### Site not loading after deployment
```bash
# Check if files were deployed
ls -la /var/www/html

# Check Nginx configuration
sudo nginx -t

# View access logs
sudo tail -f /var/log/nginx/access.log
```

## Useful Commands

```bash
# View deployment directory
ls -la /var/www/html

# Check Nginx status
sudo systemctl status nginx

# Reload Nginx (after config changes)
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Test Nginx configuration
sudo nginx -t

# Check disk space
df -h
```

## Cost Management

- **EC2 t2.micro:** Free tier includes 750 hours/month
- **Data transfer:** First 100 GB/month is free
- **Stop instance when not in use:** Right-click instance → Instance State → Stop

**Note:** Stopping the instance will change its public IP unless you use an Elastic IP (which may incur charges).

## Next Steps

Once deployment is working, you can:
1. Set up a custom domain name
2. Add HTTPS with Let's Encrypt
3. Set up monitoring and alerts
4. Proceed to Phase 3: Docker deployment

