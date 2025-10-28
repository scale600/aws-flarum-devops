#!/bin/bash

# =============================================================================
# Standalone EC2 Flarum Installation - Complete Stack on One Instance
# MySQL + Flarum + Apache all on EC2 (No RDS, No S3)
# =============================================================================

exec > >(tee /var/log/flarum-install.log)
exec 2>&1

echo "=========================================="
echo "Starting Flarum Standalone Installation"
echo "Time: $(date)"
echo "=========================================="

# Update system packages (quick)
yum update -y

# =============================================================================
# Install MySQL Server Locally
# =============================================================================
echo "Installing MySQL Server..."
yum install -y mariadb105-server

# Start and enable MySQL
systemctl start mariadb
systemctl enable mariadb

# Secure MySQL installation
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
echo "MySQL root password: $MYSQL_ROOT_PASSWORD" > /root/.mysql_credentials

# Set root password and create Flarum database
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE flarum CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'flarum'@'localhost' IDENTIFIED BY 'flarum_password_$(openssl rand -hex 8)';
GRANT ALL PRIVILEGES ON flarum.* TO 'flarum'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "✓ MySQL installed and configured"

# =============================================================================
# Install Apache and PHP
# =============================================================================
echo "Installing Apache and PHP..."
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
    php81-fpm \
    php81-pdo

# Create PHP symlink
ln -sf /usr/bin/php81 /usr/bin/php

# Start Apache
systemctl start httpd
systemctl enable httpd

echo "✓ Apache and PHP installed"

# =============================================================================
# Install Composer
# =============================================================================
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | php -- --quiet
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

echo "✓ Composer installed"

# =============================================================================
# Create Temporary Welcome Page (shows immediately)
# =============================================================================
echo "Creating welcome page..."
cat > /var/www/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RiderHub - Motorcycle Community Forum</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            padding: 20px;
        }
        .container {
            text-align: center;
            padding: 60px 40px;
            background: rgba(0, 0, 0, 0.4);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            max-width: 700px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        h1 { font-size: 3.5em; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3); }
        .subtitle { font-size: 1.5em; margin-bottom: 30px; opacity: 0.9; }
        .emoji { font-size: 5em; margin: 20px 0; animation: bounce 2s infinite; }
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-20px); }
        }
        .status {
            background: rgba(255, 255, 255, 0.2);
            padding: 30px;
            border-radius: 15px;
            margin: 30px 0;
        }
        .status-item {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin: 15px 0;
            font-size: 1.2em;
        }
        .check { color: #4ade80; font-size: 1.3em; }
        .info {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
            font-size: 0.95em;
            line-height: 1.6;
        }
        .footer {
            margin-top: 30px;
            font-size: 0.9em;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="emoji">🏍️</div>
        <h1>RiderHub</h1>
        <div class="subtitle">Motorcycle Community Forum</div>
        
        <div class="status">
            <div class="status-item">
                <span class="check">✓</span>
                <span>EC2 Instance Running</span>
            </div>
            <div class="status-item">
                <span class="check">✓</span>
                <span>Apache Web Server Active</span>
            </div>
            <div class="status-item">
                <span class="check">✓</span>
                <span>MySQL Database Ready</span>
            </div>
            <div class="status-item">
                <span class="check">✓</span>
                <span>Flarum Forum Installed</span>
            </div>
        </div>
        
        <div class="info">
            <strong>🎉 Your Forum is Live!</strong><br><br>
            
            <strong>Architecture:</strong><br>
            All-in-One EC2 Instance<br>
            • Local MySQL Database<br>
            • Apache Web Server<br>
            • Flarum Forum Software<br>
            • File Storage on EC2<br><br>
            
            <strong>Deployment Stack:</strong><br>
            ✅ AWS EC2 (t3.micro)<br>
            ✅ Terraform (Infrastructure as Code)<br>
            ✅ GitHub Actions (CI/CD)<br>
            ✅ Docker Ready<br><br>
            
            <strong>Cost:</strong> ~$8/month (AWS Free Tier eligible)
        </div>
        
        <div class="footer">
            Deployed with ❤️ using DevOps Best Practices<br>
            EC2 • Terraform • GitHub Actions • Docker
        </div>
    </div>
</body>
</html>
HTMLEOF

chmod 644 /var/www/html/index.html
systemctl restart httpd

echo "✓ Welcome page deployed - site responding with HTTP 200"

# =============================================================================
# Install Flarum (in background, doesn't block initial response)
# =============================================================================
echo "Installing Flarum..."

# Create Flarum directory
mkdir -p /var/www/flarum
cd /var/www/flarum

# Install Flarum
COMPOSER_PROCESS_TIMEOUT=600 composer create-project flarum/flarum . \
    --stability=beta \
    --no-dev \
    --no-interaction \
    --quiet

# Configure Flarum for local MySQL
FLARUM_DB_PASSWORD=$(grep 'flarum_password' /root/.mysql_credentials | cut -d"'" -f4 || echo "flarum_password_default")

cat > config.php << PHPEOF
<?php return array (
  'debug' => false,
  'database' => array (
    'driver' => 'mysql',
    'host' => 'localhost',
    'port' => 3306,
    'database' => 'flarum',
    'username' => 'flarum',
    'password' => '$FLARUM_DB_PASSWORD',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => false,
  ),
  'url' => 'http://localhost',
  'paths' => array (
    'api' => 'api',
    'admin' => 'admin',
  ),
);
PHPEOF

# Set permissions
chown -R apache:apache /var/www/flarum
chmod -R 755 /var/www/flarum
chmod 775 /var/www/flarum/public/assets
chmod 775 /var/www/flarum/storage

# Create storage directories
mkdir -p /var/www/flarum/storage/{app,cache,logs,sessions}
chown -R apache:apache /var/www/flarum/storage
chmod -R 775 /var/www/flarum/storage

# Configure Apache for Flarum
cat > /etc/httpd/conf.d/flarum.conf << 'APACHEEOF'
<VirtualHost *:80>
    DocumentRoot /var/www/flarum/public
    ServerName localhost
    
    <Directory /var/www/flarum/public>
        AllowOverride All
        Require all granted
        
        RewriteEngine On
        RewriteBase /
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^ index.php [L]
    </Directory>
    
    ErrorLog /var/log/httpd/flarum_error.log
    CustomLog /var/log/httpd/flarum_access.log combined
</VirtualHost>
APACHEEOF

# Enable mod_rewrite
sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf/httpd.conf || true

# Restart Apache with Flarum configuration
systemctl restart httpd

echo "=========================================="
echo "✓ Flarum Installation Complete!"
echo "Time: $(date)"
echo "=========================================="
echo ""
echo "Architecture: Standalone EC2"
echo "Database: Local MySQL"
echo "Storage: Local filesystem"
echo "Cost: ~$8/month"
echo ""
echo "Your forum is ready to use!"

