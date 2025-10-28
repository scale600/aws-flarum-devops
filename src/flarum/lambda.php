<?php
/**
 * RiderHub Flarum Lambda Handler
 *
 * This file serves as the entry point for the Flarum OSS application
 * running on AWS Lambda with API Gateway integration using Bref.
 *
 * @package RiderHub\Flarum
 * @author Richard Lee
 * @version 1.0.0
 */

require __DIR__ . '/vendor/autoload.php';

use Bref\Context\Context;
use Bref\Event\Http\HttpRequestEvent;

/**
 * Set up environment variables for Flarum
 */
function setupEnvironment(): void
{
    // Set required environment variables
    $_ENV['APP_ENV'] = $_ENV['APP_ENV'] ?? 'production';
    $_ENV['APP_DEBUG'] = $_ENV['APP_DEBUG'] ?? 'false';
    $_ENV['APP_URL'] = $_ENV['APP_URL'] ?? 'https://localhost';
    
    // Database configuration
    $_ENV['DB_CONNECTION'] = $_ENV['DB_CONNECTION'] ?? 'mysql';
    $_ENV['DB_HOST'] = $_ENV['DB_HOST'] ?? 'localhost';
    $_ENV['DB_PORT'] = $_ENV['DB_PORT'] ?? '3306';
    $_ENV['DB_DATABASE'] = $_ENV['DB_DATABASE'] ?? 'flarum';
    $_ENV['DB_USERNAME'] = $_ENV['DB_USERNAME'] ?? 'flarum';
    $_ENV['DB_PASSWORD'] = $_ENV['DB_PASSWORD'] ?? '';
    
    // File system configuration
    $_ENV['FILESYSTEM_DISK'] = $_ENV['FILESYSTEM_DISK'] ?? 's3';
}

/**
 * Create HTTP response
 */
function createResponse(int $statusCode, array $data): array
{
    return [
        'statusCode' => $statusCode,
        'headers' => [
            'Content-Type' => 'application/json',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization'
        ],
        'body' => json_encode($data, JSON_PRETTY_PRINT)
    ];
}

/**
 * Create HTML response
 */
function createHtmlResponse(int $statusCode, string $html): array
{
    return [
        'statusCode' => $statusCode,
        'headers' => [
            'Content-Type' => 'text/html; charset=utf-8',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization'
        ],
        'body' => $html
    ];
}

/**
 * Generate home page HTML
 */
function generateHomePage(): string
{
    return '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RiderHub Flarum Forum</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px;
        }
        .header {
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }
        .header h1 {
            font-size: 3rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .header p {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        .card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .feature {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            border-left: 4px solid #667eea;
        }
        .feature h3 {
            color: #667eea;
            margin-bottom: 10px;
        }
        .endpoints {
            background: #e3f2fd;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .endpoint {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #ddd;
        }
        .endpoint:last-child { border-bottom: none; }
        .method {
            background: #4caf50;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        .status {
            background: #4caf50;
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            display: inline-block;
            margin: 20px 0;
        }
        .footer {
            text-align: center;
            color: white;
            margin-top: 40px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏍️ RiderHub</h1>
            <p>Flarum Community Forum - Serverless Edition</p>
            <div class="status">✅ Online & Running</div>
        </div>

        <div class="card">
            <h2>Welcome to RiderHub Flarum Forum!</h2>
            <p>Your motorcycle community forum is now running on AWS Lambda with a serverless architecture.</p>
            
            <div class="features">
                <div class="feature">
                    <h3>💬 Discussions</h3>
                    <p>Engage in meaningful conversations</p>
                </div>
                <div class="feature">
                    <h3>📝 Posts</h3>
                    <p>Share your thoughts and experiences</p>
                </div>
                <div class="feature">
                    <h3>👥 User Management</h3>
                    <p>Complete user registration and profiles</p>
                </div>
                <div class="feature">
                    <h3>⚡ Real-time Updates</h3>
                    <p>Stay connected with live notifications</p>
                </div>
                <div class="feature">
                    <h3>🗄️ MySQL Database</h3>
                    <p>Reliable data storage with RDS</p>
                </div>
                <div class="feature">
                    <h3>📁 S3 File Storage</h3>
                    <p>Scalable media and file management</p>
                </div>
            </div>

            <div class="endpoints">
                <h3>Available Endpoints</h3>
                <div class="endpoint">
                    <span><span class="method">GET</span> /</span>
                    <span>Forum home page (this page)</span>
                </div>
                <div class="endpoint">
                    <span><span class="method">GET</span> /api</span>
                    <span>API documentation</span>
                </div>
                <div class="endpoint">
                    <span><span class="method">GET</span> /status</span>
                    <span>System status (JSON)</span>
                </div>
            </div>
        </div>

        <div class="card">
            <h3>System Information</h3>
            <p><strong>Version:</strong> 1.8.0</p>
            <p><strong>PHP Version:</strong> ' . PHP_VERSION . '</p>
            <p><strong>Environment:</strong> ' . ($_ENV['APP_ENV'] ?? 'production') . '</p>
            <p><strong>Last Updated:</strong> ' . date('Y-m-d H:i:s T') . '</p>
        </div>

        <div class="footer">
            <p>Powered by AWS Lambda • Built with Bref • Deployed via GitHub Actions</p>
        </div>
    </div>
</body>
</html>';
}

/**
 * Generate API documentation page
 */
function generateApiPage(): string
{
    return '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Documentation - RiderHub Flarum</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        .header { 
            background: #2c3e50; 
            color: white; 
            padding: 30px; 
            border-radius: 10px; 
            margin-bottom: 30px;
            text-align: center;
        }
        .card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .endpoint {
            border: 1px solid #ddd;
            border-radius: 8px;
            margin: 20px 0;
            overflow: hidden;
        }
        .endpoint-header {
            background: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #ddd;
        }
        .method {
            background: #28a745;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: bold;
            margin-right: 10px;
        }
        .url {
            font-family: monospace;
            background: #e9ecef;
            padding: 4px 8px;
            border-radius: 4px;
        }
        .endpoint-body {
            padding: 20px;
        }
        .response-example {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 15px;
            margin: 10px 0;
            font-family: monospace;
            white-space: pre-wrap;
        }
        .back-link {
            display: inline-block;
            background: #007bff;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="/" class="back-link">← Back to Home</a>
        
        <div class="header">
            <h1>🚀 API Documentation</h1>
            <p>RiderHub Flarum Forum API Reference</p>
        </div>

        <div class="card">
            <h2>Base URL</h2>
            <p><code>https://5qck6fcg34.execute-api.us-east-1.amazonaws.com/production</code></p>
        </div>

        <div class="endpoint">
            <div class="endpoint-header">
                <span class="method">GET</span>
                <span class="url">/</span>
                <span>Home Page</span>
            </div>
            <div class="endpoint-body">
                <p>Returns the main forum homepage with HTML content.</p>
                <h4>Response:</h4>
                <div class="response-example">HTML page with forum information and features</div>
            </div>
        </div>

        <div class="endpoint">
            <div class="endpoint-header">
                <span class="method">GET</span>
                <span class="url">/status</span>
                <span>System Status</span>
            </div>
            <div class="endpoint-body">
                <p>Returns system status information in JSON format.</p>
                <h4>Response Example:</h4>
                <div class="response-example">{
  "status": "ok",
  "php_version": "8.1.32",
  "timestamp": "2025-10-28T04:30:42+00:00",
  "environment": "production"
}</div>
            </div>
        </div>

        <div class="endpoint">
            <div class="endpoint-header">
                <span class="method">GET</span>
                <span class="url">/api</span>
                <span>API Documentation</span>
            </div>
            <div class="endpoint-body">
                <p>Returns this API documentation page.</p>
                <h4>Response:</h4>
                <div class="response-example">HTML page with API documentation</div>
            </div>
        </div>

        <div class="card">
            <h3>Testing the API</h3>
            <p>You can test these endpoints using curl:</p>
            <div class="response-example"># Home page
curl "https://5qck6fcg34.execute-api.us-east-1.amazonaws.com/production/"

# Status endpoint
curl "https://5qck6fcg34.execute-api.us-east-1.amazonaws.com/production/status"

# API documentation
curl "https://5qck6fcg34.execute-api.us-east-1.amazonaws.com/production/api"</div>
        </div>
    </div>
</body>
</html>';
}

/**
 * Generate 404 error page
 */
function generate404Page(string $path): string
{
    return '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - RiderHub Flarum</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
            min-height: 100vh;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container { text-align: center; }
        .error-code { font-size: 8rem; font-weight: bold; margin-bottom: 20px; }
        .error-message { font-size: 1.5rem; margin-bottom: 30px; }
        .path { 
            background: rgba(255,255,255,0.2); 
            padding: 10px 20px; 
            border-radius: 25px; 
            font-family: monospace;
            margin: 20px 0;
        }
        .back-link {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 25px;
            margin-top: 20px;
            transition: background 0.3s;
        }
        .back-link:hover { background: rgba(255,255,255,0.3); }
    </style>
</head>
<body>
    <div class="container">
        <div class="error-code">404</div>
        <div class="error-message">Page Not Found</div>
        <div class="path">Path: ' . htmlspecialchars($path) . '</div>
        <p>The requested endpoint does not exist.</p>
        <a href="/" class="back-link">← Go Home</a>
    </div>
</body>
</html>';
}

/**
 * Main handler function for processing API Gateway requests
 */
return function ($event, Context $context): array {
    try {
        // Set up environment variables
        setupEnvironment();
        
        // Log the event for debugging
        error_log("Received event: " . json_encode($event));
        
        // Handle null or invalid event data
        if (empty($event) || !is_array($event)) {
            error_log("Invalid event data received: " . json_encode($event));
            return createResponse(400, [
                'error' => 'Invalid request',
                'message' => 'Event data is missing or invalid',
                'event' => $event
            ]);
        }
        
        // Create HTTP request event
        $request = new HttpRequestEvent($event);
        
        // Get request information
        $path = $request->getPath();
        $method = $request->getMethod();
        
        error_log("Processing request: $method $path");

        // Simulate Flarum application logic
        if ($path === '/') {
            return createHtmlResponse(200, generateHomePage());
        } elseif ($path === '/status') {
            // Keep status as JSON for API usage
            return createResponse(200, [
                'status' => 'ok',
                'php_version' => PHP_VERSION,
                'timestamp' => date('c'),
                'environment' => $_ENV['APP_ENV'] ?? 'production'
            ]);
        } elseif ($path === '/api') {
            return createHtmlResponse(200, generateApiPage());
        } else {
            return createHtmlResponse(404, generate404Page($path));
        }
    } catch (Exception $e) {
        error_log("Flarum Lambda Error: " . $e->getMessage());
        error_log("Stack trace: " . $e->getTraceAsString());
        
        return createResponse(500, [
            'error' => 'Internal server error',
            'message' => $e->getMessage()
        ]);
    }
};