<?php
/**
 * RiderHub Application Bootstrap
 * 
 * This file initializes the Flarum application with AWS-specific configuration
 * for serverless deployment on AWS Lambda.
 * 
 * @package RiderHub
 * @author Richard Lee
 * @version 1.0.0
 */

use Flarum\Foundation\Application;
use Flarum\Foundation\Config;

// =============================================================================
// Configuration Constants
// =============================================================================
const DEFAULT_APP_ENV = 'production';
const DEFAULT_APP_DEBUG = false;
const DEFAULT_APP_URL = 'https://riderhub.amplifyapp.com';
const DEFAULT_AWS_REGION = 'us-east-1';
const DEFAULT_DATABASE_NAME = 'riderhub';
const DEFAULT_S3_BUCKET = 'riderhub-media';
const DEFAULT_SESSION_LIFETIME = 120;
const DEFAULT_SESSION_COOKIE = 'flarum_session';

// =============================================================================
// Environment Configuration
// =============================================================================
$appEnvironment = $_ENV['APP_ENV'] ?? DEFAULT_APP_ENV;
$isDebugMode = filter_var($_ENV['APP_DEBUG'] ?? DEFAULT_APP_DEBUG, FILTER_VALIDATE_BOOLEAN);

// =============================================================================
// Flarum Application Configuration
// =============================================================================
$config = new Config([
    'debug' => $isDebugMode,
    'url' => $_ENV['APP_URL'] ?? DEFAULT_APP_URL,
    'database' => [
        'driver' => 'dynamodb',
        'host' => $_ENV['DYNAMODB_ENDPOINT'] ?? null,
        'database' => $_ENV['DYNAMODB_DATABASE'] ?? DEFAULT_DATABASE_NAME,
        'username' => $_ENV['AWS_ACCESS_KEY_ID'] ?? null,
        'password' => $_ENV['AWS_SECRET_ACCESS_KEY'] ?? null,
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'prefix' => '',
        'strict' => true,
        'engine' => null,
        'options' => [
            'region' => $_ENV['AWS_REGION'] ?? DEFAULT_AWS_REGION,
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
        'lifetime' => DEFAULT_SESSION_LIFETIME,
        'expire_on_close' => false,
        'encrypt' => false,
        'files' => storage_path('framework/sessions'),
        'connection' => null,
        'table' => 'sessions',
        'store' => null,
        'lottery' => [2, 100],
        'cookie' => DEFAULT_SESSION_COOKIE,
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
                'region' => $_ENV['AWS_REGION'] ?? DEFAULT_AWS_REGION,
                'bucket' => $_ENV['S3_MEDIA_BUCKET'] ?? DEFAULT_S3_BUCKET,
                'url' => null,
                'endpoint' => null,
                'use_path_style_endpoint' => false,
                'throw' => false
            ]
        ]
    ]
]);

return new Application($config);
