<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    // GET /api/categories
    // Mengembalikan daftar kategori + jumlah post terbit per kategori (alias "count")
    public function index()
    {
        $cats = Category::select('id', 'name', 'slug')
            ->withCount([
                'posts as count' => function ($q) {
                    $q->where('is_published', true);
                },
            ])
            ->orderBy('name')
            ->get();

        return response()->json($cats);
    }

    // GET /api/categories/{slug}/posts
    // Mengembalikan post yang terbit pada kategori {slug}
    public function posts(string $slug, Request $request)
    {
        $limit = (int) $request->query('limit', 0);

        $category = Category::where('slug', $slug)->firstOrFail();

        $q = $category->posts()
            ->with('category')
            ->where('is_published', true)
            ->orderByDesc('published_at')
            ->orderByDesc('created_at');

        if ($limit > 0) {
            $q->limit($limit);
        }

        return response()->json($q->get());
    }
}
