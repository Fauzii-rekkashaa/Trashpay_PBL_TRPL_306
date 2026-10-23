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
    Schema::create('antrean_setoran', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
        $table->foreignId('jadwal_id')->constrained('jadwal_penyetoran')->onDelete('cascade');
        $table->integer('nomor_antrean');
        $table->enum('status', ['menunggu', 'dipanggil', 'sedang_dilayani', 'selesai', 'dibatalkan'])->default('menunggu');
        $table->timestamp('waktu_daftar')->useCurrent();
        $table->timestamp('waktu_dipanggil')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('antrean_setoran');
    }
};
