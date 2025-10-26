<?php

require __DIR__ . '/vendor/autoload.php';

use Bref\Context\Context;
use Bref\Event\ApiGateway\ApiGatewayEvent;
use Bref\Event\ApiGateway\ApiGatewayResponse;
use Bref\Event\ApiGateway\ApiGatewayHandler;

class RiderHubHandler extends ApiGatewayHandler
{
    public function handleRequest(ApiGatewayEvent $event, Context $context): ApiGatewayResponse
    {
        // Initialize Flarum application
        $app = require __DIR__ . '/bootstrap/app.php';
        
        // Handle the request
        $request = $this->createRequestFromEvent($event);
        $response = $app->handle($request);
        
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
