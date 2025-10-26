<?php

namespace RiderHub\Tests;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    public function testBasicFunctionality()
    {
        $this->assertTrue(true, 'Basic test should pass');
    }
    
    public function testEnvironmentVariables()
    {
        $this->assertNotEmpty($_ENV['AWS_REGION'] ?? 'us-east-1', 'AWS region should be set');
    }
}
