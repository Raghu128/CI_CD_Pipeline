# CI/CD Pipeline Learning Project

A Task Management Dashboard built with React, TypeScript, and Tailwind CSS, featuring a complete CI/CD pipeline deployment to AWS EC2.

## Features

- ✅ Task CRUD operations (Create, Read, Update, Delete)
- 🏷️ Task categories with color coding (Work, Personal, Shopping, Health, Other)
- 🔍 Search and filter functionality
- 🌓 Dark/light theme toggle
- 💾 Local storage persistence
- 📱 Responsive design
- 🎨 Modern UI with Tailwind CSS

## Project Structure

```
CI_CD_Pipleine/
├── Frontend/              # React application
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── App.tsx       # Main application
│   │   └── index.css     # Tailwind CSS
│   ├── dist/             # Production build (generated)
│   └── package.json
├── .github/
│   └── workflows/        # GitHub Actions CI/CD workflows
└── README.md
```

## Local Development

1. **Install dependencies:**
   ```bash
   cd Frontend
   npm install
   ```

2. **Run development server:**
   ```bash
   npm run dev
   ```

3. **Build for production:**
   ```bash
   npm run build
   ```

4. **Preview production build:**
   ```bash
   npm run preview
   ```

## GitHub Setup

To push this repository to GitHub:

1. **Create a new repository on GitHub** (don't initialize with README)

2. **Add remote and push:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git push -u origin main
   ```

## AWS EC2 Deployment Setup

### Prerequisites
- AWS account with IAM user credentials
- EC2 instance (t2.micro recommended for free tier)

### EC2 Instance Setup

1. **Launch EC2 Instance:**
   - AMI: Ubuntu Server 22.04 LTS
   - Instance Type: t2.micro
   - Security Group: Allow SSH (22) and HTTP (80)

2. **Connect to EC2 and install Nginx:**
   ```bash
   sudo apt update
   sudo apt install -y nginx
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```

3. **Configure Nginx:**
   ```bash
   sudo tee /etc/nginx/sites-available/default << 'EOF'
   server {
       listen 80 default_server;
       listen [::]:80 default_server;
       
       root /var/www/html;
       index index.html;
       
       server_name _;
       
       location / {
           try_files $uri $uri/ /index.html;
       }
   }
   EOF
   
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Set up deployment directory:**
   ```bash
   sudo mkdir -p /var/www/html
   sudo chown -R ubuntu:ubuntu /var/www/html
   ```

### GitHub Actions Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `EC2_HOST`: Your EC2 public IP address
- `EC2_USERNAME`: `ubuntu` (default for Ubuntu AMIs)
- `EC2_SSH_KEY`: Your private SSH key (the .pem file content)

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) automatically:
1. Installs dependencies
2. Builds the React application
3. Deploys to EC2 via SSH
4. Restarts Nginx

Triggered on every push to the `main` branch.

## Docker Deployment

For the Docker-based deployment phase:

1. **Build Docker image:**
   ```bash
   cd Frontend
   docker build -t task-manager .
   ```

2. **Run container:**
   ```bash
   docker run -p 3000:80 task-manager
   ```

## Technologies Used

- **Frontend:** React 19, TypeScript, Vite
- **Styling:** Tailwind CSS v4
- **CI/CD:** GitHub Actions
- **Deployment:** AWS EC2, Nginx
- **Containerization:** Docker (Phase 4)

## Learning Objectives

This project teaches:
- GitHub Actions workflow configuration
- AWS EC2 setup and management
- Docker containerization
- CI/CD pipeline design
- Nginx web server configuration
- SSH automation and security
- Infrastructure management

## License

MIT License - Feel free to use this project for learning purposes.

# Deployment test
# Deployment with all secrets configured
