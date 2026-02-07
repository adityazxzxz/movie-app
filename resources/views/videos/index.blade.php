<x-app-layout>
<div class="container mx-auto">

    <form method="GET" class="mb-4 mt-3">
        <input type="text" name="q" value="{{ $search }}"
            placeholder="Search video..."
            class="w-full border rounded px-3 py-2">
    </form>

    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
        @forelse ($videos as $video)
            <div class="bg-white rounded shadow">
                <img src="{{ $video['thumbnail'] ?? asset('img/default-thumb.png') }}"
                     class="w-full h-[200px] object-cover rounded-t">

                <div class="p-3 text-center">
                    <h6 class="text-sm font-medium mb-2">
                        {{ $video['title'] }}
                    </h6>

                    <a href="{{ route('videos.watch', $video['filename']) }}"
                       class="inline-block bg-blue-600 text-white text-sm px-3 py-1 rounded">
                        ▶ Watch
                    </a>
                </div>
            </div>
        @empty
            <p class="col-span-full text-center text-gray-500">
                No video found.
            </p>
        @endforelse
    </div>
</div>
</x-app-layout>
