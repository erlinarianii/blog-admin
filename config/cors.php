<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Atur siapa saja (domain/frontend) yang boleh akses API Laravel kamu.
    | Kalau pakai Next.js, biasanya localhost:3000 untuk development
    | dan domain deploy (misalnya vercel.app) untuk production.
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
    'http://localhost:3000',
    'https://my-portfolio.vercel.app',
],


    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
