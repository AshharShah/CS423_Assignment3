#!/usr/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install apache2 -y

sudo systemctl start apache2

sudo echo "<h1> Welcome To My EC2 Server <h1/>" > /var/www/html/index.html

echo "Script Execution Complete!"