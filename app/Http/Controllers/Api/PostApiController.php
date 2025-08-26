<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;

class PostApiController extends Controller
{
    public function index(Request $request)
    {
        $posts = Post::query()
            ->where('is_published', true)
            ->orderByDesc('published_at')
            ->paginate(10);

        return response()->json($posts);
    }

    public function show($slug)
    {
        $post = Post::where('slug', $slug)
            ->where('is_published', true)
            ->firstOrFail();

        return response()->json($post);
    }
}
