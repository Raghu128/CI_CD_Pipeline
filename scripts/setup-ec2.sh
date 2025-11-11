#!/bin/bash

# EC2 Setup Script for Task Manager Deployment
# Run this script on your EC2 instance after launching it

set -e

echo "=========================================="
echo "Task Manager - EC2 Setup Script"
echo "=========================================="
echo ""

# Update system packages
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Nginx
echo "🌐 Installing Nginx..."
sudo apt install -y nginx

# Start and enable Nginx
echo "🚀 Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure Nginx for React app
echo "⚙️  Configuring Nginx..."
sudo tee /etc/nginx/sites-available/default > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html;
    
    server_name _;
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Test Nginx configuration
echo "✅ Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx
echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

# Create deployment directory
echo "📁 Creating deployment directory..."
sudo mkdir -p /var/www/html
sudo chown -R ubuntu:ubuntu /var/www/html

# Create a placeholder index.html
echo "📝 Creating placeholder page..."
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager - Deployment Ready</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
        }
        h1 { font-size: 3rem; margin-bottom: 1rem; }
        p { font-size: 1.2rem; opacity: 0.9; }
        .status { 
            display: inline-block;
            background: rgba(255,255,255,0.2);
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            margin-top: 1rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 EC2 Instance Ready!</h1>
        <p>Your server is configured and waiting for deployment.</p>
        <div class="status">✅ Nginx is running</div>
    </div>
</body>
</html>
EOF

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "=========================================="
echo "✅ EC2 Setup Complete!"
echo "=========================================="
echo ""
echo "Your server is ready at: http://${PUBLIC_IP}"
echo ""
echo "Next steps:"
echo "1. Add EC2_HOST='${PUBLIC_IP}' to GitHub Secrets"
echo "2. Add EC2_USERNAME='ubuntu' to GitHub Secrets"
echo "3. Add your EC2_SSH_KEY (private key) to GitHub Secrets"
echo "4. Push your code to GitHub to trigger deployment"
echo ""
echo "To view Nginx logs:"
echo "  sudo tail -f /var/log/nginx/access.log"
echo "  sudo tail -f /var/log/nginx/error.log"
echo ""

