<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up(): void
{
    Schema::create('transaksi_setoran', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
        $table->foreignId('petugas_id')->nullable()->constrained('users')->onDelete('set null');
        $table->foreignId('jenis_id')->constrained('jenis_sampah')->onDelete('restrict');
        $table->decimal('berat_kg', 8, 2);
        $table->decimal('nilai_rupiah', 12, 2);
        $table->string('foto_bukti_path')->nullable();
        $table->enum('status_setoran', ['diajukan', 'diperiksa', 'selesai', 'ditolak'])->default('diajukan');
        $table->timestamp('tanggal')->useCurrent();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transaksi_setoran');
    }
};
