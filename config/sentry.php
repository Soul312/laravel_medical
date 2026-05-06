<?php

return [
    'dsn' => env('SENTRY_LARAVEL_DSN'),

    // The release version of your application
    // Example with Git: exec('git rev-parse --short HEAD')
    'release' => env('SENTRY_RELEASE'),

    'environment' => env('SENTRY_ENVIRONMENT', 'production'),

    'breadcrumbs' => [
        'logs' => true,
        'sql_queries' => true,
        'sql_bindings' => true,
        'queue_info' => true,
        'command_info' => true,
    ],

    'tracing' => [
        'spans' => [
            'routing' => true,
            'database' => true,
            'queue' => true,
            'view' => true,
        ],
    ],

    'traces_sample_rate' => (float)env('SENTRY_TRACES_SAMPLE_RATE', 1.0),
];
