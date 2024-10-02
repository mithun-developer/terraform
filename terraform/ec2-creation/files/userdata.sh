#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo service httpd start
sudo chkconfig on
cd /var/www/html
echo “Test Application“ | sudo tee /var/www/html/index.html