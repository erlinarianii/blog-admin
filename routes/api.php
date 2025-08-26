<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PostApiController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Endpoint untuk diakses dari frontend (misalnya Next.js).
| Semua route di sini otomatis diawali dengan /api
| Contoh: http://localhost:8000/api/posts
|
*/

// contoh route bawaan Laravel (opsional)
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// route untuk posts
Route::get('/posts', [PostApiController::class, 'index']);
Route::get('/posts/{slug}', [PostApiController::class, 'show']);
