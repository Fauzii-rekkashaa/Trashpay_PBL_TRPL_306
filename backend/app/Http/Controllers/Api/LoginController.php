<?php

// Simpan sebagai: app/Http/Controllers/Api/LoginController.php  (timpa yang lama)

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class LoginController extends Controller
{
    /**
     * POST /api/login   { "identitas": "email atau no HP", "password": "..." }
     *
     * Respons sukses : 200 { token, user: {id, name, email, no_hp, role, saldo_aktif, status_akun} }
     * Kredensial salah: 401 pesan GENERIK (tidak membedakan email salah / sandi salah)
     * Akun belum aktif: 403 { message }
     *
     * Keamanan: bcrypt (Hash::check), throttle di route, pesan error generik,
     * token Sanctum baru per login, dan setiap percobaan dicatat di audit_log.
     */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'identitas' => ['required', 'string', 'max:150'],
            'password'  => ['required', 'string', 'max:255'],
        ]);

        $identitas = trim($data['identitas']);

        $user = str_contains($identitas, '@')
            ? User::where('email', strtolower($identitas))->first()
            : User::where('no_hp', $this->normalizePhone($identitas))->first();

        // Hash::check tetap dipanggil walau user tidak ada, supaya waktu respons relatif sama.
        // Hash cadangan HARUS bcrypt yang valid, kalau tidak Hash::check melempar error 500.
        $hashPembanding = $user?->password
            ?? '$2y$12$yj2K0QKVTN2296m8M.wMx.37LJ8NH76b4AgxTy.aUAjs0as4nRZhi';

        if (! Hash::check($data['password'], $hashPembanding) || ! $user) {
            Audit::catat(
                'login', 'user', $user?->id, 'gagal',
                userId: $user?->id,
                detail: 'kredensial salah; identitas=' . Audit::samarkan($identitas),
            );

            return response()->json([
                'message' => 'Email/nomor HP atau kata sandi salah.',
            ], 401);
        }

        if ($user->status_akun !== 'aktif') {
            Audit::catat(
                'login', 'user', $user->id, 'gagal',
                userId: $user->id,
                detail: 'akun tidak aktif: ' . $user->status_akun,
            );

            $pesan = match ($user->status_akun) {
                'menunggu_verifikasi' => 'Akun Anda masih menunggu verifikasi petugas.',
                default               => 'Akun Anda tidak aktif. Hubungi pengurus RT / admin.',
            };

            return response()->json(['message' => $pesan], 403);
        }

        $token = $user->createToken('trashpay-mobile')->plainTextToken;

        Audit::catat('login', 'user', $user->id, 'berhasil', userId: $user->id);

        return response()->json([
            'token' => $token,
            'user'  => [
                'id'          => $user->id,
                'name'        => $user->name,
                'email'       => $user->email,
                'no_hp'       => $user->no_hp,
                'role'        => $user->role,
                'saldo_aktif' => $user->saldo_aktif,
                'status_akun' => $user->status_akun,
            ],
        ]);
    }

    /** POST /api/logout  (header Authorization: Bearer <token>) */
    public function logout(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $request->user()->currentAccessToken()->delete();

        Audit::catat('logout', 'user', $userId, 'berhasil', userId: $userId);

        return response()->json(['message' => 'Berhasil keluar.']);
    }

    private function normalizePhone(string $raw): string
    {
        $digits = preg_replace('/\D+/', '', $raw) ?? '';

        if (str_starts_with($digits, '62')) {
            $digits = '0' . substr($digits, 2);
        }

        return $digits;
    }
}
