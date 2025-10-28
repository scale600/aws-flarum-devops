#!/bin/bash

# =============================================================================
# Flarum Core Installation Script for Amazon Linux 2
# =============================================================================

set -e

# Update system
yum update -y

# Install required packages
yum install -y \
    httpd \
    php81 \
    php81-cli \
    php81-common \
    php81-json \
    php81-mbstring \
    php81-xml \
    php81-zip \
    php81-mysqlnd \
    php81-opcache \
    php81-gd \
    php81-curl \
    php81-intl \
    php81-bcmath \
    php81-fileinfo \
    php81-fpm \
    php81-pdo \
    mysql \
    git \
    unzip \
    wget \
    curl

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create symlink for PHP
ln -s /usr/bin/php81 /usr/bin/php

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Create Flarum directory
mkdir -p /var/www/flarum
cd /var/www/flarum

# Install Flarum
composer create-project flarum/flarum . --stability=beta

# Set permissions
chown -R apache:apache /var/www/flarum
chmod -R 755 /var/www/flarum

# Configure Apache
cat > /etc/httpd/conf.d/flarum.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/flarum
    ServerName localhost
    
    <Directory /var/www/flarum>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /var/log/httpd/flarum_error.log
    CustomLog /var/log/httpd/flarum_access.log combined
</VirtualHost>
EOF

# Enable mod_rewrite
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf/httpd.conf

# Create Flarum configuration
cat > /var/www/flarum/config.php << EOF
<?php return array(
    'debug' => false,
    'database' => array(
        'driver'   => 'mysql',
        'host'     => '${db_host}',
        'database' => '${db_name}',
        'username' => '${db_username}',
        'password' => '${db_password}',
        'charset'  => 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'prefix'   => '',
        'port'     => '3306',
        'strict'   => false,
    ),
    'url' => 'http://localhost',
    'paths' => array(
        'api'   => 'api',
        'admin' => 'admin',
    ),
    'version' => '1.8.0',
    'extensions' => array(
        'enabled' => array(),
        'disabled' => array(),
    ),
    'settings' => array(
        'allow_sign_up' => true,
        'welcome_title' => 'Welcome to RiderHub Flarum Forum!',
        'welcome_message' => 'This is your motorcycle community forum.',
        'default_locale' => 'en',
        'default_timezone' => 'UTC',
        'forum_title' => 'RiderHub Forum',
        'forum_description' => 'A motorcycle community forum built with Flarum.',
    ),
    'mail' => array(
        'driver' => 'mail',
    ),
    'queue' => array(
        'default' => 'sync',
    ),
    'session' => array(
        'driver' => 'file',
    ),
    'cache' => array(
        'default' => 'file',
    ),
    'filesystem' => array(
        'default' => 'local',
        'disks' => array(
            'local' => array(
                'driver' => 'local',
                'root' => '/var/www/flarum/storage/app',
            ),
        ),
    ),
);
EOF

# Set proper permissions
chown apache:apache /var/www/flarum/config.php
chmod 644 /var/www/flarum/config.php

# Create storage directories
mkdir -p /var/www/flarum/storage/{app,cache,logs,sessions}
chown -R apache:apache /var/www/flarum/storage
chmod -R 775 /var/www/flarum/storage

# Create bootstrap cache directory
mkdir -p /var/www/flarum/bootstrap/cache
chown -R apache:apache /var/www/flarum/bootstrap/cache
chmod -R 775 /var/www/flarum/bootstrap/cache

# Install AWS CLI for S3 integration
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Configure AWS CLI (will be done via IAM role)
mkdir -p /home/ec2-user/.aws
cat > /home/ec2-user/.aws/config << EOF
[default]
region = ${aws_region}
output = json
EOF

# Restart Apache
systemctl restart httpd

# Create a simple health check script
cat > /var/www/flarum/health.php << 'EOF'
<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'ok',
    'service' => 'Flarum Core',
    'version' => '1.8.0',
    'timestamp' => date('c'),
    'php_version' => PHP_VERSION
]);
?>
EOF

# Log completion
echo "Flarum installation completed at $(date)" >> /var/log/flarum-install.log

# Signal completion (optional for EC2 without CloudFormation)
echo "Flarum installation completed successfully"
