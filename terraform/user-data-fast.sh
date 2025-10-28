#!/bin/bash

# =============================================================================
# Fast Flarum Installation Script - Optimized for Speed
# =============================================================================

exec > >(tee /var/log/flarum-install.log)
exec 2>&1

echo "Starting Flarum installation at $(date)"

# Skip system update to save 5-10 minutes
# yum update -y  # DISABLED for faster deployment

# Install only essential packages
echo "Installing packages..."
yum install -y httpd php81 php81-cli php81-mbstring php81-xml php81-mysqlnd git

# Start Apache
systemctl start httpd
systemctl enable httpd

# Create PHP symlink
ln -sf /usr/bin/php81 /usr/bin/php

# Install Composer quickly
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | php -- --quiet
mv composer.phar /usr/local/bin/composer

# Create a simple test page first (so site responds quickly)
echo "Creating test page..."
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>RiderHub - Installing</title>
    <meta http-equiv="refresh" content="30">
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(0, 0, 0, 0.3);
            border-radius: 10px;
        }
        .spinner {
            border: 5px solid #f3f3f3;
            border-top: 5px solid #667eea;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏍️ RiderHub Forum</h1>
        <div class="spinner"></div>
        <h2>Installing Flarum...</h2>
        <p>This page will automatically refresh.</p>
        <p>Installation usually takes 5-10 minutes.</p>
        <p><small>Started: $(date)</small></p>
    </div>
</body>
</html>
EOF

chmod 644 /var/www/html/index.html

# Restart Apache so the test page is immediately available
systemctl restart httpd

echo "Test page deployed - site should now respond with HTTP 200"

# Now install Flarum in the background
echo "Installing Flarum (this takes a few minutes)..."

# Create Flarum directory
mkdir -p /var/www/flarum
cd /var/www/flarum

# Install Flarum with minimal extensions for speed
COMPOSER_PROCESS_TIMEOUT=600 composer create-project flarum/flarum . --stability=beta --no-dev --no-interaction

# Set permissions
chown -R apache:apache /var/www/flarum
chmod -R 755 /var/www/flarum

# Configure Apache for Flarum
cat > /etc/httpd/conf.d/flarum.conf << 'APACHEEOF'
<VirtualHost *:80>
    DocumentRoot /var/www/flarum/public
    ServerName localhost
    
    <Directory /var/www/flarum/public>
        AllowOverride All
        Require all granted
        
        # Flarum rewrite rules
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

# Restart Apache with Flarum config
systemctl restart httpd

echo "Flarum installation completed at $(date)"
echo "Visit your site to complete the Flarum setup wizard"

