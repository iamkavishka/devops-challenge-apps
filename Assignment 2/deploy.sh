################Shell script to perform the following automation#################
#Clone the application
#Build the application
#Restart the application
#####################################################################################


#!/bin/bash

# Exit on any error
set -e

# Log file for debugging
LOG_FILE="/tmp/deploy.log"
echo "Starting deployment at $(date)" | tee -a $LOG_FILE

# Step 1: Clone the application
echo "Cloning the devops-challenge-apps repository..." | tee -a $LOG_FILE
REPO_DIR="/home/azureuser/devops-challenge-apps"

# Remove the directory if it exists to ensure a fresh clone
if [ -d "$REPO_DIR" ]; then
    rm -rf $REPO_DIR
fi

# Clone the repository
git clone https://github.com/iamkavishka/devops-challenge-apps.git $REPO_DIR >> $LOG_FILE 2>&1
cd $REPO_DIR
echo "Repository cloned successfully" | tee -a $LOG_FILE

# Step 2: Build the application
echo "Building the web app..." | tee -a $LOG_FILE
cd webapp
npm install >> $LOG_FILE 2>&1
echo "Web app built successfully" | tee -a $LOG_FILE

echo "Building the API..." | tee -a $LOG_FILE
cd ../api
npm install >> $LOG_FILE 2>&1
echo "API built successfully" | tee -a $LOG_FILE

# Step 3: Restart the application using pm2
echo "Restarting the applications with pm2..." | tee -a $LOG_FILE

# Stop any existing processes
pm2 delete all >> $LOG_FILE 2>&1 || true  # Ignore errors if no processes exist

# Start the web app (port 3000)
cd ../webapp
pm2 start npm --name "webapp" -- start -- --port 3000 >> $LOG_FILE 2>&1

# Start the API (port 3001)
cd ../api
pm2 start npm --name "api" -- start -- --port 3001 >> $LOG_FILE 2>&1

# Save the pm2 process list to restart on reboot
pm2 save >> $LOG_FILE 2>&1

echo "Applications restarted successfully" | tee -a $LOG_FILE
echo "Deployment completed at $(date)" | tee -a $LOG_FILE
