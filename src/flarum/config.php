<?php
/**
 * RiderHub Flarum Configuration
 *
 * Main configuration file for Flarum application
 *
 * @package RiderHub\Flarum
 * @author Richard Lee
 * @version 1.0.0
 */

return [
    /**
     * Application Configuration
     */
    'app' => [
        'name' => getenv('APP_NAME') ?: 'RiderHub Flarum Forum',
        'env' => getenv('APP_ENV') ?: 'production',
        'debug' => filter_var(getenv('APP_DEBUG'), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?: false,
        'url' => getenv('APP_URL') ?: 'http://localhost',
        'timezone' => getenv('DEFAULT_TIMEZONE') ?: 'UTC',
        'locale' => getenv('DEFAULT_LOCALE') ?: 'en',
    ],

    /**
     * Database Configuration
     */
    'database' => [
        'default' => getenv('DB_CONNECTION') ?: 'mysql',
        'connections' => [
            'mysql' => [
                'driver' => 'mysql',
                'host' => getenv('DB_HOST') ?: 'localhost',
                'port' => getenv('DB_PORT') ?: '3306',
                'database' => getenv('DB_DATABASE') ?: 'flarum',
                'username' => getenv('DB_USERNAME') ?: 'root',
                'password' => getenv('DB_PASSWORD') ?: '',
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_unicode_ci',
                'prefix' => '',
                'strict' => false,
                'engine' => null,
            ],
        ],
    ],

    /**
     * Filesystem Configuration
     */
    'filesystems' => [
        'default' => getenv('FILESYSTEM_DISK') ?: 'local',
        'disks' => [
            'local' => [
                'driver' => 'local',
                'root' => __DIR__ . '/storage/app',
            ],
            's3' => [
                'driver' => 's3',
                'key' => getenv('AWS_ACCESS_KEY_ID'),
                'secret' => getenv('AWS_SECRET_ACCESS_KEY'),
                'region' => getenv('AWS_DEFAULT_REGION') ?: 'us-east-1',
                'bucket' => getenv('AWS_BUCKET'),
            ],
        ],
    ],

    /**
     * Cache Configuration
     */
    'cache' => [
        'default' => getenv('CACHE_DRIVER') ?: 'file',
        'stores' => [
            'file' => [
                'driver' => 'file',
                'path' => __DIR__ . '/storage/framework/cache',
            ],
            'array' => [
                'driver' => 'array',
            ],
        ],
    ],

    /**
     * Session Configuration
     */
    'session' => [
        'driver' => getenv('SESSION_DRIVER') ?: 'file',
        'lifetime' => 120,
        'expire_on_close' => false,
        'path' => __DIR__ . '/storage/framework/sessions',
        'cookie' => [
            'name' => 'riderhub_session',
            'secure' => getenv('APP_ENV') === 'production',
            'http_only' => true,
            'same_site' => 'lax',
        ],
    ],

    /**
     * Queue Configuration
     */
    'queue' => [
        'default' => getenv('QUEUE_CONNECTION') ?: 'sync',
        'connections' => [
            'sync' => [
                'driver' => 'sync',
            ],
        ],
    ],

    /**
     * Mail Configuration
     */
    'mail' => [
        'default' => getenv('MAIL_DRIVER') ?: 'log',
        'mailers' => [
            'smtp' => [
                'transport' => 'smtp',
                'host' => getenv('MAIL_HOST'),
                'port' => getenv('MAIL_PORT') ?: 587,
                'encryption' => getenv('MAIL_ENCRYPTION') ?: 'tls',
                'username' => getenv('MAIL_USERNAME'),
                'password' => getenv('MAIL_PASSWORD'),
            ],
            'log' => [
                'transport' => 'log',
                'channel' => 'mail',
            ],
        ],
        'from' => [
            'address' => getenv('MAIL_FROM_ADDRESS') ?: 'noreply@riderhub.com',
            'name' => getenv('MAIL_FROM_NAME') ?: 'RiderHub Forum',
        ],
    ],

    /**
     * Logging Configuration
     */
    'logging' => [
        'default' => getenv('LOG_CHANNEL') ?: 'stack',
        'channels' => [
            'stack' => [
                'driver' => 'stack',
                'channels' => ['cloudwatch', 'stderr'],
            ],
            'cloudwatch' => [
                'driver' => 'cloudwatch',
                'name' => 'riderhub-flarum',
                'region' => getenv('AWS_DEFAULT_REGION') ?: 'us-east-1',
            ],
            'stderr' => [
                'driver' => 'monolog',
                'handler' => 'StreamHandler',
                'with' => [
                    'stream' => 'php://stderr',
                ],
            ],
        ],
    ],

    /**
     * Forum Configuration
     */
    'forum' => [
        'title' => getenv('FORUM_TITLE') ?: 'RiderHub - Motorcycle Community',
        'description' => getenv('FORUM_DESCRIPTION') ?: 'A community forum for motorcycle enthusiasts',
        'allow_sign_up' => filter_var(getenv('ALLOW_SIGN_UP'), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? true,
        'welcome_title' => 'Welcome to RiderHub!',
        'welcome_message' => 'Share your riding experiences, gear reviews, and connect with fellow riders.',
    ],

    /**
     * AWS Lambda Configuration
     */
    'lambda' => [
        'task_root' => getenv('LAMBDA_TASK_ROOT') ?: '/var/task',
        'runtime_dir' => getenv('LAMBDA_RUNTIME_DIR') ?: '/var/runtime',
    ],

    /**
     * Bref Configuration
     */
    'bref' => [
        'binary_responses' => filter_var(getenv('BREF_BINARY_RESPONSES'), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? true,
        'ping_disable' => filter_var(getenv('BREF_PING_DISABLE'), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? false,
    ],
];

