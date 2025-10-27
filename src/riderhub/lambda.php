<?php
/**
 * RiderHub Lambda Handler
 * 
 * This file serves as the entry point for the RiderHub Flarum application
 * running on AWS Lambda with API Gateway integration.
 * 
 * @package RiderHub
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
class RiderHubHandler extends ApiGatewayHandler
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
            // Simple test response for now
            $path = $event->getPath();
            $method = $event->getMethod();
            
            if ($path === '/posts' && $method === 'GET') {
                $response = [
                    'message' => 'RiderHub API is working!',
                    'path' => $path,
                    'method' => $method,
                    'timestamp' => date('Y-m-d H:i:s'),
                    'environment' => $_ENV['APP_ENV'] ?? 'unknown',
                    'debug' => $_ENV['APP_DEBUG'] ?? 'unknown'
                ];
                
                return new ApiGatewayResponse(200, ['Content-Type' => 'application/json'], json_encode($response));
            }
            
            // Default response
            $response = [
                'message' => 'RiderHub API Gateway is working!',
                'path' => $path,
                'method' => $method,
                'timestamp' => date('Y-m-d H:i:s'),
                'available_endpoints' => ['/posts']
            ];
            
            return new ApiGatewayResponse(200, ['Content-Type' => 'application/json'], json_encode($response));
            
        } catch (Exception $e) {
            $errorResponse = [
                'error' => 'Internal server error',
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ];
            
            return new ApiGatewayResponse(500, ['Content-Type' => 'application/json'], json_encode($errorResponse));
        }
    }
    
    private function createRequestFromEvent(ApiGatewayEvent $event): \Psr\Http\Message\RequestInterface
    {
        $method = $event->getMethod();
        $uri = $event->getUri();
        $headers = $event->getHeaders();
        $body = $event->getBody();
        
        return new \GuzzleHttp\Psr7\Request($method, $uri, $headers, $body);
    }
    
    private function createResponseFromSymfonyResponse($response): ApiGatewayResponse
    {
        $statusCode = $response->getStatusCode();
        $headers = $response->headers->all();
        $body = $response->getContent();
        
        return new ApiGatewayResponse($statusCode, $headers, $body);
    }
}

return new RiderHubHandler();
