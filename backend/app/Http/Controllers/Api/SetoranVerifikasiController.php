<?php

// Simpan sebagai: app/Http/Controllers/Api/SetoranVerifikasiController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * POST /api/setoran/{id}/verifikasi   { "keputusan": "diterima" | "ditolak" }
 *
 * Hanya role petugas / pengurus (otorisasi berbasis role).
 *
 * Satu proses = beberapa perubahan data yang HARUS atomic (ATS poin 13-15):
 *   1. ubah status setoran (menunggu -> diterima/ditolak) + catat petugas
 *   2. kalau diterima: tambah saldo_aktif warga sebesar nilai_rupiah
 *   3. catat audit_log
 * Semuanya dibungkus DB::transaction: sukses -> COMMIT, ada error -> ROLLBACK.
 *
 * Concurrency: baris setoran dikunci (lockForUpdate) lalu status dicek ulang,
 * jadi dua petugas yang menekan "terima" bersamaan tidak bisa menambah saldo dua kali.
 * Saldo ditambah dengan increment (saldo = saldo + x), bukan baca-hitung-tulis,
 * supaya tidak terjadi lost update.
 */
class SetoranVerifikasiController extends Controller
{
    // Sesuai tabel transaksi_setoran: status_setoran ENUM('diajukan','diperiksa','selesai','ditolak')
    private const KOLOM_STATUS = 'status_setoran';
    private const STATUS_BISA_DIPROSES = ['diajukan', 'diperiksa'];   // belum final
    private const STATUS_SELESAI = 'selesai';                          // = diterima, saldo bertambah
    private const STATUS_DITOLAK = 'ditolak';

    public function __invoke(Request $request, int $id): JsonResponse
    {
        $petugas = $request->user();

        if (! in_array($petugas->role, ['petugas', 'pengurus'], true)) {
            Audit::catat('verifikasi_setoran', 'transaksi_setoran', $id, 'gagal',
                userId: $petugas->id, detail: 'role tidak berwenang: ' . $petugas->role);

            return response()->json(['message' => 'Anda tidak berwenang memverifikasi setoran.'], 403);
        }

        $data = $request->validate([
            'keputusan' => ['required', 'in:diterima,ditolak'],
        ]);

        try {
            $hasil = DB::transaction(function () use ($id, $data, $petugas) {
                // Kunci baris setoran sampai transaksi selesai.
                $setoran = DB::table('transaksi_setoran')->where('id', $id)->lockForUpdate()->first();

                if (! $setoran) {
                    throw new \DomainException('Setoran tidak ditemukan.', 404);
                }

                // Cek ulang SETELAH dikunci: kalau sudah diproses petugas lain, berhenti.
                if (! in_array($setoran->{self::KOLOM_STATUS}, self::STATUS_BISA_DIPROSES, true)) {
                    throw new \DomainException('Setoran ini sudah diproses sebelumnya.', 409);
                }

                DB::table('transaksi_setoran')->where('id', $id)->update([
                    self::KOLOM_STATUS => $data['keputusan'] === 'diterima'
                        ? self::STATUS_SELESAI
                        : self::STATUS_DITOLAK,
                    'petugas_id'       => $petugas->id,
                ]);

                $saldoBaru = null;

                if ($data['keputusan'] === 'diterima') {
                    // Kunci baris warga, lalu tambah saldo secara atomic di database.
                    DB::table('users')->where('id', $setoran->user_id)->lockForUpdate()->first();
                    DB::table('users')->where('id', $setoran->user_id)
                        ->increment('saldo_aktif', $setoran->nilai_rupiah);

                    $saldoBaru = DB::table('users')->where('id', $setoran->user_id)->value('saldo_aktif');
                }

                // Dicatat di dalam transaksi yang sama: kalau di-rollback, log ini ikut batal.
                Audit::catat('verifikasi_setoran', 'transaksi_setoran', $id, 'berhasil',
                    userId: $petugas->id,
                    detail: "keputusan={$data['keputusan']}; nilai={$setoran->nilai_rupiah}");

                return [
                    'setoran_id'  => $id,
                    'status'      => $data['keputusan'],
                    'saldo_warga' => $saldoBaru,
                ];
            });
        } catch (\DomainException $e) {
            // Transaksi sudah di-ROLLBACK otomatis. Catat kegagalannya di luar transaksi.
            Audit::catat('verifikasi_setoran', 'transaksi_setoran', $id, 'gagal',
                userId: $petugas->id, detail: $e->getMessage());

            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 422);
        }

        return response()->json(['message' => 'Setoran berhasil diverifikasi.', 'data' => $hasil]);
    }
}
