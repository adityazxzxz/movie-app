<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\VideoController;
use Illuminate\Support\Facades\Route;

// Route::get('/', function () {
//     return view('welcome');
// });

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::middleware(['auth'])->group(function () {
    Route::get('/', [VideoController::class, 'index'])->name('videos.index');
    Route::get('/watch/{filename}', [VideoController::class, 'watch'])->name('videos.watch');
    Route::get('/thumbnail/{filename}', [VideoController::class, 'thumbnail'])
    ->name('videos.thumbnail');
    });

require __DIR__.'/auth.php';
