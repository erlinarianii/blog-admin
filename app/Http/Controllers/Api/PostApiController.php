<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Post;

class PostApiController extends Controller
{
    // Semua post (paginate)
    public function index()
    {
        $posts = Post::with('category')
            ->where('is_published', true)
            ->orderByDesc('published_at')
            ->paginate(10);

        return response()->json($posts);
    }

    // Detail post by slug
    public function show($slug)
    {
        $post = Post::with('category')
            ->where('slug', $slug)
            ->where('is_published', true)
            ->firstOrFail();

        return response()->json($post);
    }

    // Create post
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title'       => 'required|string|max:255',
            'slug'        => 'required|string|unique:posts,slug',
            'excerpt'     => 'nullable|string',
            'cover_image' => 'nullable|string',
            'body'        => 'required|string',
            'category_id' => 'required|exists:categories,id',
        ]);

        $validated['is_published'] = true; // default published
        $validated['published_at'] = now();

        $post = Post::create($validated);

        return response()->json($post, 201);
    }
}
