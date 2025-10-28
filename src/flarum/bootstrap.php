<?php
/**
 * RiderHub Flarum Bootstrap
 *
 * Initializes the Flarum application environment for AWS Lambda
 *
 * @package RiderHub\Flarum
 * @author Richard Lee
 * @version 1.0.0
 */

require __DIR__ . '/vendor/autoload.php';

use Dotenv\Dotenv;

/**
 * Load environment variables
 */
if (file_exists(__DIR__ . '/.env')) {
    $dotenv = Dotenv::createImmutable(__DIR__);
    $dotenv->load();
}

/**
 * Set error reporting based on environment
 */
if (getenv('APP_ENV') === 'production') {
    error_reporting(E_ALL & ~E_DEPRECATED & ~E_STRICT);
    ini_set('display_errors', '0');
} else {
    error_reporting(E_ALL);
    ini_set('display_errors', '1');
}

/**
 * Set timezone
 */
date_default_timezone_set(getenv('DEFAULT_TIMEZONE') ?: 'UTC');

/**
 * Configure PHP settings for Lambda
 */
ini_set('memory_limit', '512M');
ini_set('max_execution_time', '30');
ini_set('upload_max_filesize', '10M');
ini_set('post_max_size', '10M');

/**
 * Set up error handler
 */
set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    if (!(error_reporting() & $errno)) {
        return false;
    }
    
    error_log("PHP Error [$errno]: $errstr in $errfile on line $errline");
    
    if ($errno === E_ERROR || $errno === E_CORE_ERROR || $errno === E_COMPILE_ERROR) {
        throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
    }
    
    return true;
});

/**
 * Set up exception handler
 */
set_exception_handler(function ($exception) {
    error_log("Uncaught Exception: " . $exception->getMessage());
    error_log("Stack trace: " . $exception->getTraceAsString());
    
    http_response_code(500);
    
    if (getenv('APP_ENV') === 'production') {
        echo json_encode([
            'error' => 'Internal Server Error',
            'message' => 'An unexpected error occurred'
        ]);
    } else {
        echo json_encode([
            'error' => 'Internal Server Error',
            'message' => $exception->getMessage(),
            'trace' => $exception->getTrace()
        ]);
    }
});

return [
    'app_name' => getenv('APP_NAME') ?: 'RiderHub Flarum',
    'app_env' => getenv('APP_ENV') ?: 'production',
    'app_debug' => filter_var(getenv('APP_DEBUG'), FILTER_VALIDATE_BOOLEAN),
    'app_url' => getenv('APP_URL') ?: 'http://localhost',
];

