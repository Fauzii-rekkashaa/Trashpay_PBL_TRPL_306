<?php

// Simpan sebagai: app/Http/Controllers/Api/ForgotPasswordController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password as PasswordRule;

class ForgotPasswordController extends Controller
{
    /**
     * POST /api/forgot-password   { "identitas": "email atau no HP" }
     *
     * Keamanan:
     *  - Respons SELALU sama (200) baik akun ada maupun tidak -> mencegah user enumeration.
     *  - Dibatasi throttle di route (5 permintaan / menit).
     *  - Token disimpan sebagai HASH di tabel password_reset_tokens dan kedaluwarsa
     *    sesuai config/auth.php (passwords.users.expire, default 60 menit).
     */
    public function send(Request $request)
    {
        $data = $request->validate([
            'identitas' => ['required', 'string', 'max:100'],
        ]);

        $identitas = trim($data['identitas']);

        // Hanya email yang dikirimi tautan. No. WhatsApp: belum ada gateway -> tetap balas generik.
        if (str_contains($identitas, '@')) {
            // Hasil (status) sengaja diabaikan supaya tidak membocorkan apakah email terdaftar.
            Password::sendResetLink(['email' => strtolower($identitas)]);
        }

        return response()->json([
            'message' => 'Jika akun terdaftar, tautan reset kata sandi telah dikirim.',
            'cooldown_seconds' => 60,
        ]);
    }

    /**
     * POST /api/reset-password   { "token", "email", "password", "password_confirmation" }
     * Dipanggil setelah warga membuka tautan dari email.
     */
    public function reset(Request $request)
    {
        $data = $request->validate([
            'token'    => ['required', 'string'],
            'email'    => ['required', 'email'],
            'password' => ['required', 'confirmed', PasswordRule::min(8)->letters()->numbers()],
        ]);

        $status = Password::reset(
            $data,
            function ($user, $password) {
                $user->forceFill([
                    'password' => Hash::make($password), // bcrypt
                    'remember_token' => Str::random(60),
                ])->save();

                // Cabut semua token sesi lama (Sanctum) setelah sandi berubah.
                if (method_exists($user, 'tokens')) {
                    $user->tokens()->delete();
                }

                event(new PasswordReset($user));
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return response()->json(
                ['message' => 'Tautan tidak valid atau sudah kedaluwarsa.'],
                422
            );
        }

        return response()->json(['message' => 'Kata sandi berhasil diubah. Silakan masuk.']);
    }
}
