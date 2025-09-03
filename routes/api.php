<?php

use App\Http\Controllers\Api\CategoryApiController;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PostApiController;


// Post routes
Route::get('/posts', [PostApiController::class, 'index']);
Route::get('/posts/{slug}', [PostApiController::class, 'show']);
Route::post('/posts', [PostApiController::class, 'store']);

// Category routes
Route::get('/categories', [CategoryApiController::class, 'index']);
Route::get('/categories/{slug}', [CategoryApiController::class, 'show']);
Route::get('/categories/{slug}/posts', [CategoryApiController::class, 'posts']);
Route::post('/categories', [CategoryApiController::class, 'store']);
use App\Http\Controllers\PostController;

