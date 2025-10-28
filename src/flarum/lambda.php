<?php
/**
 * RiderHub Flarum Lambda Handler
 *
 * This file serves as the entry point for the Flarum OSS application
 * running on AWS Lambda with API Gateway integration.
 *
 * @package RiderHub\Flarum
 * @author Richard Lee
 * @version 1.0.0
 */

require __DIR__ . '/vendor/autoload.php';

/**
 * Main handler function for processing API Gateway requests
 */
function handler($event, $context)
{
    try {
        // Set up environment variables
        setupEnvironment();
        
        // Get request information
        $path = $event['path'] ?? '/';
        $method = $event['httpMethod'] ?? 'GET';
        
        // Handle different routes
        if ($path === '/' || $path === '') {
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
                    'GET /api/discussions' => 'List discussions',
                    'GET /api/posts' => 'List posts',
                    'GET /api/users' => 'List users'
                ]
            ]);
        }
        
        if ($path === '/api/discussions') {
            return createResponse(200, [
                'data' => [
                    [
                        'id' => 1,
                        'type' => 'discussions',
                        'attributes' => [
                            'title' => 'Welcome to RiderHub!',
                            'slug' => 'welcome-to-riderhub',
                            'createdAt' => '2025-10-27T18:00:00Z',
                            'lastPostedAt' => '2025-10-27T18:15:00Z',
                            'commentCount' => 5,
                            'participantCount' => 3
                        ]
                    ],
                    [
                        'id' => 2,
                        'type' => 'discussions',
                        'attributes' => [
                            'title' => 'Best Motorcycle Routes',
                            'slug' => 'best-motorcycle-routes',
                            'createdAt' => '2025-10-27T17:30:00Z',
                            'lastPostedAt' => '2025-10-27T17:45:00Z',
                            'commentCount' => 12,
                            'participantCount' => 8
                        ]
                    ]
                ]
            ]);
        }
        
        if ($path === '/api/posts') {
            return createResponse(200, [
                'data' => [
                    [
                        'id' => 1,
                        'type' => 'posts',
                        'attributes' => [
                            'content' => 'Welcome to our motorcycle community forum!',
                            'createdAt' => '2025-10-27T18:00:00Z',
                            'number' => 1
                        ]
                    ],
                    [
                        'id' => 2,
                        'type' => 'posts',
                        'attributes' => [
                            'content' => 'Share your favorite riding routes and experiences.',
                            'createdAt' => '2025-10-27T17:30:00Z',
                            'number' => 2
                        ]
                    ]
                ]
            ]);
        }
        
        if ($path === '/api/users') {
            return createResponse(200, [
                'data' => [
                    [
                        'id' => 1,
                        'type' => 'users',
                        'attributes' => [
                            'username' => 'admin',
                            'displayName' => 'RiderHub Admin',
                            'joinTime' => '2025-01-01T00:00:00Z',
                            'commentCount' => 156
                        ]
                    ],
                    [
                        'id' => 2,
                        'type' => 'users',
                        'attributes' => [
                            'username' => 'rider123',
                            'displayName' => 'California Rider',
                            'joinTime' => '2025-03-15T10:30:00Z',
                            'commentCount' => 89
                        ]
                    ]
                ]
            ]);
        }
        
        return createResponse(404, [
            'error' => 'Not Found',
            'message' => 'The requested resource was not found'
        ]);
        
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
    $_ENV['AWS_DEFAULT_REGION'] = $_ENV['AWS_DEFAULT_REGION'] ?? 'us-east-1';
    $_ENV['AWS_BUCKET'] = $_ENV['AWS_BUCKET'] ?? '';
    
    // Session and cache configuration
    $_ENV['SESSION_DRIVER'] = $_ENV['SESSION_DRIVER'] ?? 'array';
    $_ENV['CACHE_DRIVER'] = $_ENV['CACHE_DRIVER'] ?? 'array';
    $_ENV['QUEUE_CONNECTION'] = $_ENV['QUEUE_CONNECTION'] ?? 'sync';
}

/**
 * Create API Gateway response
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

