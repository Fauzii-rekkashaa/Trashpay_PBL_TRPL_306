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
    Schema::create('penarikan_saldo', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
        $table->foreignId('pengurus_id')->nullable()->constrained('users')->onDelete('set null');
        $table->decimal('jumlah', 12, 2);
        $table->enum('metode', ['tunai', 'transfer'])->default('tunai');
        $table->enum('status', ['menunggu', 'disetujui', 'dicairkan', 'ditolak'])->default('menunggu');
        $table->timestamp('tanggal_pengajuan')->useCurrent();
        $table->timestamp('tanggal_cair')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('penarikan_saldo');
    }
};
