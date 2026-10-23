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
    Schema::create('konten_edukasi', function (Blueprint $table) {
        $table->id();
        $table->string('judul');
        $table->text('isi');
        $table->string('kategori')->nullable();
        $table->string('gambar_url')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('konten_edukasi');
    }
};
