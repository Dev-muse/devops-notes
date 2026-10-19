#!/bin/bash
# Redirect all stdout and stderr to a log file for easy debugging via SSH
exec > >(tee /var/log/wordpress-install.log) 2>&1

echo "Starting system update..."
yum update -y

echo "Installing Apache, PHP, and MariaDB..."
yum install -y httpd php php-mysqlnd php-json php-gd php-mbstring php-xml mariadb105-server wget

echo "Starting services..."
systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb

echo "Waiting for MariaDB to start..."
while ! mysqladmin ping -h localhost --silent; do
    sleep 2
done

echo "Configuring database..."
sudo mysql -u root <<EOF
CREATE DATABASE wordpress_db;
CREATE USER 'amuse123'@'localhost' IDENTIFIED BY 'amuse123';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'amuse123'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Downloading WordPress..."
cd /var/www/html
rm -rf *
wget -O latest.tar.gz https://wordpress.org/latest.tar.gz

echo "Extracting WordPress files..."
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress latest.tar.gz

echo "Setting permissions..."
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

echo "Restarting Apache..."
systemctl restart httpd
echo "WordPress setup completed successfully!"