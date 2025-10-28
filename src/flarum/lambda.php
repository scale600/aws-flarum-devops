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
use Bref\Event\Http\HttpResponse;

/**
 * Main handler function for processing API Gateway requests
 */
function handler($event, Context $context): HttpResponse
{
    try {
        // Set up environment variables
        setupEnvironment();
        
        // Create HTTP request event
        $request = new HttpRequestEvent($event);
        
        // Get request information
        $path = $request->getPath();
        $method = $request->getMethod();

        // Simulate Flarum application logic
        // In a real scenario, you would bootstrap Flarum and dispatch the request
        // For now, we'll return a simple response based on the path

        if ($path === '/') {
            return createResponse(200, [
                'message' => 'Welcome to RiderHub Flarum Forum!',
                'version' => '1.8.0',
                'features' => [
                    'Discussions',
                    'Posts',
                    'User Management',
                    'Real-time Updates',
                    'MySQL Database',
                    'S3 File Storage'
                ],
                'endpoints' => [
                    'GET /' => 'Forum home page',
                    'GET /api' => 'API documentation',
                    'GET /status' => 'System status'
                ]
            ]);
        } elseif ($path === '/status') {
            return createResponse(200, [
                'status' => 'ok',
                'php_version' => PHP_VERSION,
                'timestamp' => date('c'),
                'environment' => $_ENV['APP_ENV'] ?? 'production'
            ]);
        } else {
            return createResponse(404, [
                'error' => 'Not Found',
                'path' => $path,
                'message' => 'The requested endpoint does not exist'
            ]);
        }
    } catch (Exception $e) {
        error_log("Flarum Lambda Error: " . $e->getMessage());
        error_log("Stack trace: " . $e->getTraceAsString());
        
        return createResponse(500, [
            'error' => 'Internal server error',
            'message' => $e->getMessage()
        ]);
    }
}

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
    // AWS_REGION and AWS_BUCKET are typically set by Lambda environment or Terraform
    // $_ENV['AWS_REGION'] = $_ENV['AWS_REGION'] ?? 'us-east-1';
    // $_ENV['AWS_BUCKET'] = $_ENV['AWS_BUCKET'] ?? 'your-s3-bucket-name';
}

/**
 * Create HTTP response
 */
function createResponse(int $statusCode, array $data): HttpResponse
{
    return new HttpResponse(json_encode($data, JSON_PRETTY_PRINT), [
        'Content-Type' => 'application/json',
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers' => 'Content-Type, Authorization'
    ], $statusCode);
}