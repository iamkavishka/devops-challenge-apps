################Shell Script for Environment Setup##################################
#Installs Node.js and NPM.
#Installs Nginx and starts it.
#Creates Nginx configuration files
#Installs Certbot and provides instructions for provisioning SSL certificates.
####################################################################################


#!/bin/bash

# Exit on any error
set -e

# Log file for debugging
LOG_FILE="/tmp/setup.log"
echo "Starting environment setup at $(date)" | tee -a $LOG_FILE

# Step 1: Update the system and install prerequisites
echo "Updating system packages..." | tee -a $LOG_FILE
sudo apt-get update -y >> $LOG_FILE 2>&1
sudo apt-get upgrade -y >> $LOG_FILE 2>&1
sudo apt-get install -y curl software-properties-common >> $LOG_FILE 2>&1

# Step 2: Install Node.js and NPM (using NodeSource for the latest LTS version)
echo "Installing Node.js and NPM..." | tee -a $LOG_FILE
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - >> $LOG_FILE 2>&1
sudo apt-get install -y nodejs >> $LOG_FILE 2>&1

# Verify Node.js and NPM installation
node -v >> $LOG_FILE 2>&1
npm -v >> $LOG_FILE 2>&1
echo "Node.js and NPM installed successfully" | tee -a $LOG_FILE

# Step 3: Install Nginx
echo "Installing Nginx..." | tee -a $LOG_FILE
sudo apt-get install -y nginx >> $LOG_FILE 2>&1

# Start and enable Nginx
sudo systemctl start nginx >> $LOG_FILE 2>&1
sudo systemctl enable nginx >> $LOG_FILE 2>&1
echo "Nginx installed and started" | tee -a $LOG_FILE

# Step 4: Create Nginx configuration files for Web App and API
echo "Creating Nginx configuration files..." | tee -a $LOG_FILE

# Web App configuration (web.example.com)
cat <<EOF | sudo tee /etc/nginx/sites-available/web.example.com
server {
    listen 80;
    server_name web.example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# API configuration (api.example.com)
cat <<EOF | sudo tee /etc/nginx/sites-available/api.example.com
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the configurations by creating symbolic links
sudo ln -s /etc/nginx/sites-available/web.example.com /etc/nginx/sites-enabled/ >> $LOG_FILE 2>&1
sudo ln -s /etc/nginx/sites-available/api.example.com /etc/nginx/sites-enabled/ >> $LOG_FILE 2>&1

# Test Nginx configuration
sudo nginx -t >> $LOG_FILE 2>&1

# Reload Nginx to apply the configurations
sudo systemctl reload nginx >> $LOG_FILE 2>&1
echo "Nginx configurations created and applied" | tee -a $LOG_FILE

# Step 5: Install Certbot and provision SSL certificates
echo "Installing Certbot..." | tee -a $LOG_FILE
sudo apt-get install -y certbot python3-certbot-nginx >> $LOG_FILE 2>&1

# Note: Certbot requires real domains to issue certificates
# For testing, we'll skip the actual certificate issuance and print instructions
echo "Certbot installed. To provision SSL certificates, ensure web.example.com and api.example.com point to this VM's public IP." | tee -a $LOG_FILE
echo "Then run the following commands manually:" | tee -a $LOG_FILE
echo "  sudo certbot --nginx -d web.example.com --non-interactive --agree-tos --email your_email@example.com" | tee -a $LOG_FILE
echo "  sudo certbot --nginx -d api.example.com --non-interactive --agree-tos --email your_email@example.com" | tee -a $LOG_FILE

echo "Environment setup completed successfully at $(date)" | tee -a $LOG_FILE
