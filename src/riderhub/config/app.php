<?php

return [
    'name' => env('APP_NAME', 'RiderHub'),
    'env' => env('APP_ENV', 'production'),
    'debug' => env('APP_DEBUG', false),
    'url' => env('APP_URL', 'https://riderhub.amplifyapp.com'),
    'timezone' => 'UTC',
    'locale' => 'en',
    'fallback_locale' => 'en',
    'key' => env('APP_KEY', 'base64:your-app-key-here'),
    'cipher' => 'AES-256-CBC',
    
    'providers' => [
        // Flarum Core Providers
        Flarum\Foundation\Providers\AppServiceProvider::class,
        Flarum\Foundation\Providers\ConsoleServiceProvider::class,
        Flarum\Foundation\Providers\ErrorServiceProvider::class,
        Flarum\Foundation\Providers\EventServiceProvider::class,
        Flarum\Foundation\Providers\FilesystemServiceProvider::class,
        Flarum\Foundation\Providers\LogServiceProvider::class,
        Flarum\Foundation\Providers\SessionServiceProvider::class,
        Flarum\Foundation\Providers\ViewServiceProvider::class,
        
        // AWS Providers
        Aws\Laravel\AwsServiceProvider::class,
        
        // Bref Providers
        Bref\LaravelBridge\BrefServiceProvider::class,
    ],
    
    'aliases' => [
        'App' => Illuminate\Support\Facades\App::class,
        'Artisan' => Illuminate\Support\Facades\Artisan::class,
        'Auth' => Illuminate\Support\Facades\Auth::class,
        'Blade' => Illuminate\Support\Facades\Blade::class,
        'Cache' => Illuminate\Support\Facades\Cache::class,
        'Config' => Illuminate\Support\Facades\Config::class,
        'DB' => Illuminate\Support\Facades\DB::class,
        'Event' => Illuminate\Support\Facades\Event::class,
        'File' => Illuminate\Support\Facades\File::class,
        'Gate' => Illuminate\Support\Facades\Gate::class,
        'Hash' => Illuminate\Support\Facades\Hash::class,
        'Log' => Illuminate\Support\Facades\Log::class,
        'Mail' => Illuminate\Support\Facades\Mail::class,
        'Notification' => Illuminate\Support\Facades\Notification::class,
        'Queue' => Illuminate\Support\Facades\Queue::class,
        'Redirect' => Illuminate\Support\Facades\Redirect::class,
        'Request' => Illuminate\Support\Facades\Request::class,
        'Response' => Illuminate\Support\Facades\Response::class,
        'Route' => Illuminate\Support\Facades\Route::class,
        'Schema' => Illuminate\Support\Facades\Schema::class,
        'Session' => Illuminate\Support\Facades\Session::class,
        'Storage' => Illuminate\Support\Facades\Storage::class,
        'URL' => Illuminate\Support\Facades\URL::class,
        'Validator' => Illuminate\Support\Facades\Validator::class,
        'View' => Illuminate\Support\Facades\View::class,
    ],
];
