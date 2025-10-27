<?php

namespace RiderHub\Flarum\Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    public function test_basic_functionality()
    {
        $this->assertTrue(true);
    }

    public function test_environment_variables()
    {
        $this->assertIsString($_ENV['APP_ENV'] ?? 'testing');
    }

    public function test_php_version()
    {
        $this->assertGreaterThanOrEqual(8.1, PHP_VERSION_ID);
    }
}
