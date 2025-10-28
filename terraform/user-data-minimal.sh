#!/bin/bash
# Emergency fast deployment - Get site responding in under 2 minutes

exec > /var/log/flarum-quick-install.log 2>&1

echo "Quick install started at $(date)"

# Install and start Apache immediately
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create immediate response page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RiderHub - Motorcycle Community Forum</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .container {
            text-align: center;
            padding: 60px 40px;
            background: rgba(0, 0, 0, 0.4);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            max-width: 600px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        h1 { font-size: 3em; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3); }
        .emoji { font-size: 4em; margin: 20px 0; animation: bounce 2s infinite; }
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-20px); }
        }
        p { font-size: 1.2em; line-height: 1.6; margin: 15px 0; }
        .status {
            background: rgba(255, 255, 255, 0.2);
            padding: 20px;
            border-radius: 10px;
            margin: 30px 0;
        }
        .button {
            display: inline-block;
            padding: 15px 40px;
            background: white;
            color: #667eea;
            text-decoration: none;
            border-radius: 50px;
            font-weight: bold;
            margin-top: 20px;
            transition: transform 0.2s;
        }
        .button:hover { transform: scale(1.05); }
    </style>
</head>
<body>
    <div class="container">
        <div class="emoji">🏍️</div>
        <h1>RiderHub</h1>
        <p><strong>Your Motorcycle Community Forum</strong></p>
        
        <div class="status">
            <p>✅ <strong>Site is LIVE!</strong></p>
            <p>🔧 Flarum forum installation in progress...</p>
            <p>⏱️ Full setup: 5-10 more minutes</p>
        </div>
        
        <p>We're setting up your Flarum forum.</p>
        <p>Refresh this page in a few minutes to access the forum!</p>
        
        <a href="javascript:location.reload()" class="button">Refresh Page</a>
        
        <p style="margin-top: 30px; font-size: 0.9em; opacity: 0.8;">
            Deployed via AWS • EC2 + RDS + S3 + ALB
        </p>
    </div>
</body>
</html>
EOF

echo "Quick install completed at $(date) - Apache responding with test page"

