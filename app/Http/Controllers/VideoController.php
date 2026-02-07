<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Symfony\Component\HttpFoundation\StreamedResponse;

class VideoController extends Controller
{
    private string $videoPath;

    public function __construct()
    {
        $this->videoPath = config('filesystems.video_path');
    }

    public function index(Request $request)
    {
        $search = strtolower($request->query('q'));

        $videos = collect(File::files($this->videoPath))
            ->filter(fn($file) => in_array($file->getExtension(), ['mp4', 'mkv', 'webm']))
            ->map(function ($file) {
                $name = pathinfo($file->getFilename(), PATHINFO_FILENAME);

                return [
                    'filename' => $file->getFilename(),
                    'title' => $name,
                    'thumbnail' => $this->getThumbnail($name),
                ];
            })
            ->filter(function ($video) use ($search) {
                return empty($search) || str_contains(strtolower($video['title']), $search);
            })
            ->values();

        return view('videos.index', compact('videos', 'search'));
    }

    private function getThumbnail(string $name): ?string
    {
        foreach (['jpg', 'png'] as $ext) {
            $path = "{$this->videoPath}/{$name}.{$ext}";
            if (File::exists($path)) {
                return route('videos.thumbnail', "{$name}.{$ext}");
            }
        }
        return null;
    }

    public function watch(string $filename)
    {
        $path = "{$this->videoPath}/{$filename}";

        abort_if(!File::exists($path), 404);

        return response()->file($path);
    }

    public function thumbnail(string $filename)
{
    // keamanan: batasi hanya file image
    if (!preg_match('/\.(jpg|jpeg|png|webp)$/i', $filename)) {
        abort(403);
    }

    $path = $this->videoPath . '/' . $filename;

    if (!is_file($path)) {
        abort(404);
    }

    return response()->file($path, [
        'Cache-Control' => 'public, max-age=86400',
    ]);
}
}
