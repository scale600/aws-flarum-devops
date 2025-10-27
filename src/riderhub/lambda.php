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
        // Initialize Flarum application with AWS-specific configuration
        $app = require __DIR__ . '/bootstrap/app.php';
        
        // Convert API Gateway event to PSR-7 request
        $request = $this->createRequestFromEvent($event);
        
        // Process the request through Flarum application
        $response = $app->handle($request);
        
        // Convert Symfony response back to API Gateway format
        return $this->createResponseFromSymfonyResponse($response);
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
