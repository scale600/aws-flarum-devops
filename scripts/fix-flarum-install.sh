#!/bin/bash

# =============================================================================
# Fix Flarum Installation on Running EC2 Instance
# =============================================================================

set -e

# Create symlink for PHP
if [ ! -f /usr/bin/php ]; then
    ln -s /usr/bin/php81 /usr/bin/php
fi

# Install Composer if not already installed
if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

# Create Flarum directory
mkdir -p /var/www/flarum
cd /var/www/flarum

# Check if Flarum is already installed
if [ ! -f /var/www/flarum/composer.json ]; then
    # Install Flarum
    COMPOSER_ALLOW_SUPERUSER=1 /usr/local/bin/composer create-project flarum/flarum . --stability=beta --no-interaction
    
    # Set permissions
    chown -R apache:apache /var/www/flarum
    chmod -R 755 /var/www/flarum
fi

# Get RDS endpoint from environment variable or parameter
DB_HOST="${DB_HOST:-riderhub-flarum-db.cclwwqusaf9q.us-east-1.rds.amazonaws.com}"
DB_NAME="${DB_NAME:-flarum}"
DB_USERNAME="${DB_USERNAME:-flarum_admin}"
DB_PASSWORD="${DB_PASSWORD}"
S3_BUCKET="${S3_BUCKET:-riderhub-flarum-files-v6sjhj0e}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Create Flarum configuration if not exists
if [ ! -f /var/www/flarum/config.php ]; then
    cat > /var/www/flarum/config.php << EOF
<?php return array(
    'debug' => false,
    'database' => array(
        'driver'   => 'mysql',
        'host'     => '$DB_HOST',
        'database' => '$DB_NAME',
        'username' => '$DB_USERNAME',
        'password' => '$DB_PASSWORD',
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
);
EOF
    
    chown apache:apache /var/www/flarum/config.php
    chmod 644 /var/www/flarum/config.php
fi

# Create storage directories
mkdir -p /var/www/flarum/storage/{app,cache,logs,sessions}
chown -R apache:apache /var/www/flarum/storage
chmod -R 775 /var/www/flarum/storage

# Create bootstrap cache directory
mkdir -p /var/www/flarum/bootstrap/cache
chown -R apache:apache /var/www/flarum/bootstrap/cache
chmod -R 775 /var/www/flarum/bootstrap/cache

# Configure Apache
cat > /etc/httpd/conf.d/flarum.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/flarum/public
    ServerName localhost
    
    <Directory /var/www/flarum/public>
        AllowOverride All
        Require all granted
        
        # Enable PHP
        <FilesMatch \.php$>
            SetHandler "proxy:unix:/var/run/php-fpm/www.sock|fcgi://localhost"
        </FilesMatch>
    </Directory>
    
    ErrorLog /var/log/httpd/flarum_error.log
    CustomLog /var/log/httpd/flarum_access.log combined
</VirtualHost>
EOF

# Enable mod_rewrite and mod_proxy_fcgi
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf/httpd.conf
sed -i 's/#LoadModule proxy_module/LoadModule proxy_module/' /etc/httpd/conf.modules.d/00-proxy.conf || true
sed -i 's/#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/' /etc/httpd/conf.modules.d/00-proxy.conf || true

# Start PHP-FPM
systemctl start php-fpm || systemctl start php81-php-fpm || true
systemctl enable php-fpm || systemctl enable php81-php-fpm || true

# Restart Apache
systemctl restart httpd

# Create a simple health check script
cat > /var/www/flarum/public/health.php << 'EOF'
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

chown apache:apache /var/www/flarum/public/health.php

echo "Flarum installation fix completed at $(date)"

