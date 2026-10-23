<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

/**
 * POST /api/register  -> pendaftaran warga baru dari aplikasi Flutter.
 *
 * Akun baru selalu role "warga" dengan status "menunggu_verifikasi"
 * (diverifikasi petugas/pengurus lewat dashboard web), sehingga
 * endpoint ini TIDAK mengeluarkan token login.
 */
class RegisterController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        if ($request->has('no_hp')) {
            $request->merge(['no_hp' => $this->normalizePhone((string) $request->input('no_hp'))]);
        }

        $data = $request->validate([
            'name'     => ['required', 'string', 'min:3', 'max:100'],
            'nik'      => ['required', 'digits:16', 'unique:users,nik'],
            'email'    => ['required', 'email', 'max:150', 'unique:users,email'],
            'no_hp'    => ['required', 'regex:/^08[0-9]{8,11}$/', 'unique:users,no_hp'],
            'alamat'   => ['required', 'string', 'max:255'],
            'password' => ['required', 'confirmed', Password::min(8)->letters()->numbers()],
        ], [
            'name.required'      => 'Nama lengkap wajib diisi.',
            'nik.required'       => 'NIK wajib diisi.',
            'nik.digits'         => 'NIK harus 16 digit angka.',
            'nik.unique'         => 'NIK ini sudah terdaftar.',
            'email.required'     => 'Email wajib diisi.',
            'email.email'        => 'Format email tidak valid.',
            'email.unique'       => 'Email ini sudah terdaftar.',
            'no_hp.required'     => 'Nomor WhatsApp wajib diisi.',
            'no_hp.regex'        => 'Gunakan nomor Indonesia, contoh 0812xxxxxxxx.',
            'no_hp.unique'       => 'Nomor ini sudah terdaftar.',
            'alamat.required'    => 'Alamat rumah wajib diisi.',
            'password.required'  => 'Kata sandi wajib diisi.',
            'password.confirmed' => 'Konfirmasi kata sandi tidak sama.',
            'password.min'       => 'Kata sandi minimal 8 karakter.',
            'password.letters'   => 'Kata sandi harus mengandung huruf.',
            'password.numbers'   => 'Kata sandi harus mengandung angka.',
        ]);

        // Diisi satu per satu (bukan mass assignment) supaya role/status
        // tidak bisa dipalsukan dari request dan tidak bergantung $fillable.
        $user = new User();
        $user->name         = trim($data['name']);
        $user->nik          = $data['nik'];
        $user->email        = strtolower(trim($data['email']));
        $user->no_hp        = $data['no_hp'];
        $user->alamat       = trim($data['alamat']);
        $user->password     = Hash::make($data['password']);
        $user->role         = 'warga';
        $user->status_akun  = 'menunggu_verifikasi';
        $user->saldo_aktif  = 0;
        $user->save();

        return response()->json([
            'message' => 'Pendaftaran berhasil. Akun Anda menunggu verifikasi petugas.',
            'data'    => [
                'id'          => $user->id,
                'name'        => $user->name,
                'email'       => $user->email,
                'status_akun' => $user->status_akun,
            ],
        ], 201);
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
