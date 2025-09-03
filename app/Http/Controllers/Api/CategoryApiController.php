<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;

class CategoryApiController extends Controller
{
    // Semua kategori (+ count post terpublikasi)
    public function index(Request $request)
    {
        $categories = Category::query()
            ->withCount(['posts as count' => function ($q) {
                $q->where('is_published', true);
            }])
            ->orderBy('name')
            ->get();

        return response()->json($categories);
    }

    // Detail kategori by slug (+ count post terpublikasi)
    public function show(string $slug)
    {
        $category = Category::where('slug', $slug)
            ->withCount(['posts as count' => function ($q) {
                $q->where('is_published', true);
            }])
            ->firstOrFail();

        return response()->json($category);
    }

    // Semua post berdasarkan kategori slug, dukung ?published=1&limit=9
    public function posts(string $slug, Request $request)
    {
        $category = Category::where('slug', $slug)->firstOrFail();

        $q = $category->posts()
            ->with('category')
            ->orderByDesc('published_at');

        if ($request->boolean('published', true)) {
            $q->where('is_published', true);
        }

        $limit = max(1, min((int) $request->integer('limit', 9), 50));

        return response()->json($q->take($limit)->get());
    }

    // Create kategori
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['required', 'string', 'max:255', 'unique:categories,slug'],
        ]);

        $category = Category::create($validated);

        return response()->json($category, 201);
    }
}
