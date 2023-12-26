#!/usr/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y apache2 adminer mysql-server -y

sudo systemctl start mysql apache2

sudo mysql --user=root --password='' --execute="CREATE DATABASE IF NOT EXISTS test;"
sudo mysql --user=root --password='' --execute="CREATE USER IF NOT EXISTS 'ashhar'@'localhost' IDENTIFIED BY 'ashhar1234';"
sudo mysql --user=root --password='' --execute="GRANT ALL PRIVILEGES ON test.* TO 'ashhar'@'localhost';"
sudo mysql --user=root --password='' --execute="FLUSH PRIVILEGES;"

sudo ln -s /etc/apache2/conf-available/adminer.conf /etc/apache2/conf-enabled/

apachectl configtest

sudo systemctl restart apache2