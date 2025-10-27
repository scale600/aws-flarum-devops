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

use Bref\Context\Context;
use Bref\Event\ApiGateway\ApiGatewayEvent;
use Bref\Event\ApiGateway\ApiGatewayResponse;
use Bref\Event\ApiGateway\ApiGatewayHandler;

/**
 * Main handler class for processing API Gateway requests
 */
class FlarumHandler extends ApiGatewayHandler
{
    /**
     * Handle incoming API Gateway requests
     *
     * @param ApiGatewayEvent $event The API Gateway event
     * @param Context $context The Lambda context
     * @return ApiGatewayResponse The response to send back to API Gateway
     */
    public function handleRequest(ApiGatewayEvent $event, Context $context): ApiGatewayResponse
    {
        try {
            // Set up environment variables
            $this->setupEnvironment();
            
            // Create the request from the API Gateway event
            $request = $this->createRequestFromEvent($event);
            
            // Initialize Flarum application
            $app = $this->createFlarumApplication();
            
            // Handle the request through Flarum
            $response = $app->handle($request);
            
            // Convert Symfony response to API Gateway response
            return $this->createResponseFromSymfonyResponse($response);
            
        } catch (Exception $e) {
            error_log("Flarum Lambda Error: " . $e->getMessage());
            error_log("Stack trace: " . $e->getTraceAsString());
            
            $errorResponse = [
                'error' => 'Internal server error',
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ];

            return new ApiGatewayResponse(500, ['Content-Type' => 'application/json'], json_encode($errorResponse));
        }
    }

    /**
     * Set up environment variables for Flarum
     */
    private function setupEnvironment(): void
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
     * Create Flarum application instance
     */
    private function createFlarumApplication()
    {
        // This would typically initialize the full Flarum application
        // For now, we'll create a simple response handler
        
        return new class {
            public function handle($request) {
                // Simple Flarum-like response for testing
                $path = $request->getUri()->getPath();
                $method = $request->getMethod();
                
                if ($path === '/' || $path === '') {
                    return $this->createResponse(200, [
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
                    return $this->createResponse(200, [
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
                    return $this->createResponse(200, [
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
                    return $this->createResponse(200, [
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
                
                return $this->createResponse(404, [
                    'error' => 'Not Found',
                    'message' => 'The requested resource was not found'
                ]);
            }
            
            private function createResponse($statusCode, $data) {
                return new class($statusCode, $data) {
                    private $statusCode;
                    private $data;
                    
                    public function __construct($statusCode, $data) {
                        $this->statusCode = $statusCode;
                        $this->data = $data;
                    }
                    
                    public function getStatusCode() {
                        return $this->statusCode;
                    }
                    
                    public function getContent() {
                        return json_encode($this->data, JSON_PRETTY_PRINT);
                    }
                    
                    public function headers() {
                        return new class {
                            public function all() {
                                return ['Content-Type' => 'application/json'];
                            }
                        };
                    }
                };
            }
        };
    }

    /**
     * Create a PSR-7 request from API Gateway event
     */
    private function createRequestFromEvent(ApiGatewayEvent $event): \Psr\Http\Message\RequestInterface
    {
        $method = $event->getMethod();
        $uri = $event->getUri();
        $headers = $event->getHeaders();
        $body = $event->getBody();

        return new \GuzzleHttp\Psr7\Request($method, $uri, $headers, $body);
    }

    /**
     * Convert Symfony response to API Gateway response
     */
    private function createResponseFromSymfonyResponse($response): ApiGatewayResponse
    {
        $statusCode = $response->getStatusCode();
        $headers = $response->headers()->all();
        $body = $response->getContent();

        return new ApiGatewayResponse($statusCode, $headers, $body);
    }
}

return new FlarumHandler();

