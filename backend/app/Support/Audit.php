<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;

/**
 * Pencatat audit trail (tabel audit_log).
 * Mencatat: actor, action, object, timestamp (otomatis), result.
 *
 * Jangan pernah memasukkan password / token ke $detail.
 */
class Audit
{
    public static function catat(
        string $action,
        string $objectType,
        string|int|null $objectId,
        string $result,                 // 'berhasil' | 'gagal'
        ?int $userId = null,
        ?string $detail = null,
    ): void {
        try {
            DB::table('audit_log')->insert([
                'user_id'     => $userId,
                'actor'       => $userId ? "user#{$userId}" : 'anonim',
                'action'      => $action,
                'object_type' => $objectType,
                'object_id'   => $objectId !== null ? (string) $objectId : null,
                'result'      => $result,
                'ip_address'  => request()->ip(),
                'detail'      => $detail !== null ? mb_substr($detail, 0, 255) : null,
            ]);
        } catch (\Throwable $e) {
            // Kegagalan mencatat log tidak boleh membuat login/registrasi ikut gagal,
            // tapi tetap dilaporkan ke storage/logs/laravel.log.
            report($e);
        }
    }

    /** 081270984321 -> 0812*****321  (untuk detail log, supaya data pribadi tidak utuh) */
    public static function samarkan(string $teks): string
    {
        $n = mb_strlen($teks);
        if ($n <= 6) {
            return str_repeat('*', $n);
        }

        return mb_substr($teks, 0, 3) . str_repeat('*', $n - 6) . mb_substr($teks, -3);
    }
}
