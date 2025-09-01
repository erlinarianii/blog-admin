<?php
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/posts', function () {
    return Post::latest()->get();
});

Route::get('/posts/{id}', function ($id) {
    return Post::findOrFail($id);
});
