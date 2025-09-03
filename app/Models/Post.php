<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class Post extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'slug',
        'excerpt',
        'body',
        'category_id',
        'is_published',
        'published_at',
        // pakai salah satu di DB-mu: 'cover' ATAU 'cover_image'
        'cover',
        'cover_image',
        'user_id', // penting agar tidak error 1364
    ];

    protected $casts = [
        'published_at' => 'datetime',
        'is_published' => 'boolean',
    ];

    protected $appends = ['cover_url'];

    public function getCoverUrlAttribute(): ?string
    {
        $path = $this->cover ?? $this->cover_image;
        if (!$path) return null;

        // sudah absolute?
        if (Str::startsWith($path, ['http://', 'https://'])) {
            return $path;
        }

        // rapikan prefix salah: storage/app/public/, public/, dll
        $path = ltrim($path, '/');
        $path = preg_replace('#^(storage/|public/|app/public/|storage/app/public/)#', '', $path);

        return url(Storage::url($path)); // => /storage/...
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
