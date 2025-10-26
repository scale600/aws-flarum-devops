<?php

use Flarum\Foundation\Application;
use Flarum\Foundation\Config;

// Load environment variables
$env = $_ENV['APP_ENV'] ?? 'production';
$debug = filter_var($_ENV['APP_DEBUG'] ?? false, FILTER_VALIDATE_BOOLEAN);

// Create Flarum application
$config = new Config([
    'debug' => $debug,
    'url' => $_ENV['APP_URL'] ?? 'https://riderhub.amplifyapp.com',
    'database' => [
        'driver' => 'dynamodb',
        'host' => $_ENV['DYNAMODB_ENDPOINT'] ?? null,
        'database' => $_ENV['DYNAMODB_DATABASE'] ?? 'riderhub',
        'username' => $_ENV['AWS_ACCESS_KEY_ID'] ?? null,
        'password' => $_ENV['AWS_SECRET_ACCESS_KEY'] ?? null,
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'prefix' => '',
        'strict' => true,
        'engine' => null,
        'options' => [
            'region' => $_ENV['AWS_REGION'] ?? 'us-east-1',
            'version' => 'latest'
        ]
    ],
    'cache' => [
        'default' => 'array',
        'stores' => [
            'array' => [
                'driver' => 'array'
            ]
        ]
    ],
    'session' => [
        'driver' => 'array',
        'lifetime' => 120,
        'expire_on_close' => false,
        'encrypt' => false,
        'files' => storage_path('framework/sessions'),
        'connection' => null,
        'table' => 'sessions',
        'store' => null,
        'lottery' => [2, 100],
        'cookie' => 'flarum_session',
        'path' => '/',
        'domain' => null,
        'secure' => false,
        'http_only' => true,
        'same_site' => 'lax'
    ],
    'queue' => [
        'default' => 'sync',
        'connections' => [
            'sync' => [
                'driver' => 'sync'
            ]
        ]
    ],
    'filesystems' => [
        'default' => 's3',
        'disks' => [
            's3' => [
                'driver' => 's3',
                'key' => $_ENV['AWS_ACCESS_KEY_ID'] ?? null,
                'secret' => $_ENV['AWS_SECRET_ACCESS_KEY'] ?? null,
                'region' => $_ENV['AWS_REGION'] ?? 'us-east-1',
                'bucket' => $_ENV['S3_MEDIA_BUCKET'] ?? 'riderhub-media',
                'url' => null,
                'endpoint' => null,
                'use_path_style_endpoint' => false,
                'throw' => false
            ]
        ]
    ]
]);

return new Application($config);
