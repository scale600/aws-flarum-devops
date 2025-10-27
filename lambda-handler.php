<?php
/**
 * RiderHub Flarum Lambda Handler
 * 
 * This is a simplified Flarum handler for AWS Lambda
 * that provides basic forum functionality.
 */

// Simple autoloader for basic functionality
spl_autoload_register(function ($class) {
    $file = __DIR__ . '/vendor/' . str_replace('\\', '/', $class) . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

function handler($event, $context) {
    try {
        // Parse the API Gateway event
        $path = $event['path'] ?? '/';
        $method = $event['httpMethod'] ?? 'GET';
        $headers = $event['headers'] ?? [];
        $body = $event['body'] ?? '';
        
        // Set response headers
        $responseHeaders = [
            'Content-Type' => 'application/json',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization'
        ];
        
        // Handle CORS preflight
        if ($method === 'OPTIONS') {
            return [
                'statusCode' => 200,
                'headers' => $responseHeaders,
                'body' => ''
            ];
        }
        
        // Route handling
        switch ($path) {
            case '/':
                return handleHome($responseHeaders);
            case '/posts':
                return handlePosts($method, $body, $responseHeaders);
            case '/discussions':
                return handleDiscussions($method, $body, $responseHeaders);
            case '/users':
                return handleUsers($method, $body, $responseHeaders);
            case '/api/forum':
                return handleApiForum($responseHeaders);
            default:
                return handleNotFound($responseHeaders);
        }
        
    } catch (Exception $e) {
        return [
            'statusCode' => 500,
            'headers' => ['Content-Type' => 'application/json'],
            'body' => json_encode([
                'error' => 'Internal Server Error',
                'message' => $e->getMessage()
            ])
        ];
    }
}

function handleHome($headers) {
    $data = [
        'message' => 'Welcome to RiderHub Forum!',
        'version' => '1.0.0',
        'features' => [
            'Discussions',
            'Posts',
            'User Management',
            'Real-time Updates'
        ],
        'endpoints' => [
            'GET /posts' => 'List all posts',
            'GET /discussions' => 'List discussions',
            'GET /users' => 'List users',
            'GET /api/forum' => 'Forum information'
        ]
    ];
    
    return [
        'statusCode' => 200,
        'headers' => $headers,
        'body' => json_encode($data, JSON_PRETTY_PRINT)
    ];
}

function handlePosts($method, $body, $headers) {
    if ($method === 'GET') {
        // Mock posts data
        $posts = [
            [
                'id' => 1,
                'title' => 'Welcome to RiderHub!',
                'content' => 'This is our first discussion. Feel free to introduce yourself!',
                'author' => 'Admin',
                'created_at' => '2025-10-27T18:00:00Z',
                'replies' => 5
            ],
            [
                'id' => 2,
                'title' => 'Best Motorcycle Routes in California',
                'content' => 'Share your favorite motorcycle routes and scenic drives.',
                'author' => 'Rider123',
                'created_at' => '2025-10-27T17:30:00Z',
                'replies' => 12
            ],
            [
                'id' => 3,
                'title' => 'Maintenance Tips for Beginners',
                'content' => 'Essential maintenance tips every new rider should know.',
                'author' => 'MechanicMike',
                'created_at' => '2025-10-27T16:45:00Z',
                'replies' => 8
            ]
        ];
        
        return [
            'statusCode' => 200,
            'headers' => $headers,
            'body' => json_encode([
                'posts' => $posts,
                'total' => count($posts),
                'page' => 1
            ], JSON_PRETTY_PRINT)
        ];
    }
    
    if ($method === 'POST') {
        $data = json_decode($body, true);
        $newPost = [
            'id' => rand(100, 999),
            'title' => $data['title'] ?? 'New Post',
            'content' => $data['content'] ?? '',
            'author' => $data['author'] ?? 'Anonymous',
            'created_at' => date('c'),
            'replies' => 0
        ];
        
        return [
            'statusCode' => 201,
            'headers' => $headers,
            'body' => json_encode([
                'message' => 'Post created successfully',
                'post' => $newPost
            ], JSON_PRETTY_PRINT)
        ];
    }
    
    return [
        'statusCode' => 405,
        'headers' => $headers,
        'body' => json_encode(['error' => 'Method not allowed'])
    ];
}

function handleDiscussions($method, $body, $headers) {
    if ($method === 'GET') {
        $discussions = [
            [
                'id' => 1,
                'title' => 'General Discussion',
                'description' => 'General motorcycle discussions and topics',
                'post_count' => 25,
                'last_post' => '2025-10-27T18:15:00Z'
            ],
            [
                'id' => 2,
                'title' => 'Ride Reports',
                'description' => 'Share your riding experiences and trip reports',
                'post_count' => 18,
                'last_post' => '2025-10-27T17:45:00Z'
            ],
            [
                'id' => 3,
                'title' => 'Technical Support',
                'description' => 'Get help with motorcycle maintenance and repairs',
                'post_count' => 32,
                'last_post' => '2025-10-27T18:00:00Z'
            ]
        ];
        
        return [
            'statusCode' => 200,
            'headers' => $headers,
            'body' => json_encode([
                'discussions' => $discussions,
                'total' => count($discussions)
            ], JSON_PRETTY_PRINT)
        ];
    }
    
    return [
        'statusCode' => 405,
        'headers' => $headers,
        'body' => json_encode(['error' => 'Method not allowed'])
    ];
}

function handleUsers($method, $body, $headers) {
    if ($method === 'GET') {
        $users = [
            [
                'id' => 1,
                'username' => 'Admin',
                'display_name' => 'RiderHub Admin',
                'join_date' => '2025-01-01T00:00:00Z',
                'post_count' => 156
            ],
            [
                'id' => 2,
                'username' => 'Rider123',
                'display_name' => 'California Rider',
                'join_date' => '2025-03-15T10:30:00Z',
                'post_count' => 89
            ],
            [
                'id' => 3,
                'username' => 'MechanicMike',
                'display_name' => 'Mike the Mechanic',
                'join_date' => '2025-06-20T14:15:00Z',
                'post_count' => 234
            ]
        ];
        
        return [
            'statusCode' => 200,
            'headers' => $headers,
            'body' => json_encode([
                'users' => $users,
                'total' => count($users)
            ], JSON_PRETTY_PRINT)
        ];
    }
    
    return [
        'statusCode' => 405,
        'headers' => $headers,
        'body' => json_encode(['error' => 'Method not allowed'])
    ];
}

function handleApiForum($headers) {
    $forumInfo = [
        'name' => 'RiderHub',
        'description' => 'A motorcycle community forum built with Flarum on AWS Lambda',
        'version' => '1.0.0',
        'features' => [
            'Discussions and Posts',
            'User Management',
            'Real-time Updates',
            'Mobile Responsive',
            'Serverless Architecture'
        ],
        'statistics' => [
            'total_posts' => 156,
            'total_users' => 23,
            'total_discussions' => 45,
            'online_users' => 3
        ],
        'endpoints' => [
            'GET /' => 'Forum home page',
            'GET /posts' => 'List all posts',
            'POST /posts' => 'Create new post',
            'GET /discussions' => 'List discussions',
            'GET /users' => 'List users',
            'GET /api/forum' => 'Forum information'
        ]
    ];
    
    return [
        'statusCode' => 200,
        'headers' => $headers,
        'body' => json_encode($forumInfo, JSON_PRETTY_PRINT)
    ];
}

function handleNotFound($headers) {
    return [
        'statusCode' => 404,
        'headers' => $headers,
        'body' => json_encode([
            'error' => 'Not Found',
            'message' => 'The requested resource was not found',
            'available_endpoints' => [
                'GET /' => 'Forum home',
                'GET /posts' => 'List posts',
                'GET /discussions' => 'List discussions',
                'GET /users' => 'List users',
                'GET /api/forum' => 'Forum info'
            ]
        ], JSON_PRETTY_PRINT)
    ];
}
?>
