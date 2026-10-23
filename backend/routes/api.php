<?php

// Ganti isi routes/api.php dengan file ini.

use App\Http\Controllers\Api\ForgotPasswordController;
use App\Http\Controllers\Api\LoginController;
use App\Http\Controllers\Api\RegisterController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// ---------- Publik (tanpa login) ----------
Route::post('/register', RegisterController::class)
    ->middleware('throttle:10,1');

Route::post('/login', [LoginController::class, 'login'])
    ->middleware('throttle:5,1');   // batasi tebak sandi: 5x / menit per IP

Route::post('/forgot-password', [ForgotPasswordController::class, 'send'])
    ->middleware('throttle:5,1');

Route::post('/reset-password', [ForgotPasswordController::class, 'reset'])
    ->middleware('throttle:5,1');

// ---------- Perlu login (Sanctum) ----------
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/logout', [LoginController::class, 'logout']);
});
