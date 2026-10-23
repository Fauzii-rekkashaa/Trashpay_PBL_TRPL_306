import 'package:flutter/material.dart';

const Color _kGreen = Color(0xFF1B5E20);
const Color _kGreenMid = Color(0xFF2E7D32);
const Color _kMint = Color(0xFF9BF0A8);
const Color _kText = Color(0xFF16221B);
const Color _kTextGray = Color(0xFF5E6B64);
const Color _kSelectedBg = Color(0xFFE3F1F9);
const Color _kChipGray = Color(0xFFDDE8EE);
const Color _kInfoBg = Color(0xFFDDE8EE);

class JenisSampahItem {
  const JenisSampahItem({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.satuan,
    required this.icon,
    required this.warna,
    this.fotoAsset,
  });

  final int id;
  final String nama;
  final String deskripsi;
  final int harga;
  final String satuan; // 'kg' atau 'L'
  final IconData icon;
  final Color warna;
  final String? fotoAsset; // contoh: assets/images/sampah/plastik.png (opsional)

  String get hargaLabel => 'Rp${_rupiah(harga)} / $satuan';
}

String _rupiah(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

// DUMMY: ganti dengan data dari API.
const List<JenisSampahItem> _kDummyJenis = [
  JenisSampahItem(
    id: 1,
    nama: 'Plastik',
    deskripsi: 'Botol, Gelas, Emberan',
    harga: 3500,
    satuan: 'kg',
    icon: Icons.recycling_rounded,
    warna: Color(0xFF8CC7D9),
    fotoAsset: 'assets/images/sampah/plastik.png',
  ),
  JenisSampahItem(
    id: 2,
    nama: 'Kertas',
    deskripsi: 'HVS, Majalah, Koran',
    harga: 2000,
    satuan: 'kg',
    icon: Icons.description_outlined,
    warna: Color(0xFFE0C9A6),
    fotoAsset: 'assets/images/sampah/kertas.png',
  ),
  JenisSampahItem(
    id: 3,
    nama: 'Kardus',
    deskripsi: 'Dus, Karton, Kemasan',
    harga: 1800,
    satuan: 'kg',
    icon: Icons.inventory_2_outlined,
    warna: Color(0xFFC9A87C),
    fotoAsset: 'assets/images/sampah/kardus.png',
  ),
  JenisSampahItem(
    id: 4,
    nama: 'Logam',
    deskripsi: 'Kaleng, Aluminium, Tembaga',
    harga: 9000,
    satuan: 'kg',
    icon: Icons.hardware_rounded,
    warna: Color(0xFFB0BEC5),
    fotoAsset: 'assets/images/sampah/logam.png',
  ),
  JenisSampahItem(
    id: 5,
    nama: 'Botol Kaca',
    deskripsi: 'Sirop, kecap, beling',
    harga: 1200,
    satuan: 'kg',
    icon: Icons.wine_bar_outlined,
    warna: Color(0xFF9CCC9C),
    fotoAsset: 'assets/images/sampah/kaca.png',
  ),
  JenisSampahItem(
    id: 6,
    nama: 'Lainnya',
    deskripsi: 'Minyak jelantah, aki',
    harga: 6500,
    satuan: 'L',
    icon: Icons.oil_barrel_outlined,
    warna: Color(0xFFD7C28F),
    fotoAsset: 'assets/images/sampah/lainnya.png',
  ),
];

class SetoranTab extends StatefulWidget {
  const SetoranTab({super.key, this.onBack, this.onLanjut});

  /// Tombol panah kembali (biasanya pindah ke tab Beranda).
  final VoidCallback? onBack;

  /// Dipanggil saat "Lanjutkan ke Formulir Antrean" ditekan.
  final void Function(JenisSampahItem pilihan)? onLanjut;

  @override
  State<SetoranTab> createState() => _SetoranTabState();
}

class _SetoranTabState extends State<SetoranTab> {
  // TODO: ganti dengan data dari API (GET /api/jenis-sampah).
  final List<JenisSampahItem> _jenis = _kDummyJenis;
  JenisSampahItem? _dipilih;

  void _lanjut() {
    final p = _dipilih;
    if (p == null) return;
    if (widget.onLanjut != null) {
      widget.onLanjut!(p);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Formulir antrean (${p.nama}) belum tersedia.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, _dipilih == null ? 24 : 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              const SizedBox(height: 14),
              _buildProgress(),
              const SizedBox(height: 14),
              _buildInfo(),
              const SizedBox(height: 16),
              _buildGrid(),
              const SizedBox(height: 16),
              _buildGotongRoyong(),
            ],
          ),
        ),
        if (_dipilih != null)
          Positioned(left: 20, right: 20, bottom: 12, child: _buildBottomBar()),
      ],
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Material(
            color: const Color(0xFFDCE9F2),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onBack,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.arrow_back_rounded, size: 22, color: _kText),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Pilih Jenis Sampah',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _kText),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: _kSelectedBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 11,
                backgroundColor: _kGreen,
                child: Text('1',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Langkah 1 dari 4: Kategori Sampah',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kText),
                ),
              ),
              const Text(
                '25% Selesai',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _kGreen),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.25,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(_kGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: _kMint,
            child: Icon(Icons.info_outline_rounded, size: 22, color: _kGreen),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pilih kategori sampah yang akan disetorkan. Estimasi harga per kg '
              'diperbarui secara berkala oleh pengurus lingkungan.',
              style: TextStyle(fontSize: 13, height: 1.45, color: _kText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(builder: (context, c) {
      const gap = 12.0;
      final w = (c.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final j in _jenis)
            SizedBox(
              width: w,
              child: _JenisCard(
                item: j,
                selected: _dipilih?.id == j.id,
                onTap: () => setState(() => _dipilih = j),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildGotongRoyong() {
    // TODO: ambil dari API (total setoran RT minggu ini).
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kInfoBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.park_outlined, size: 28, color: _kGreen),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gotong Royong RT 05',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _kText)),
                SizedBox(height: 2),
                Text('Target setoran minggu ini: 420 kg / 500 kg (84%)',
                    style: TextStyle(fontSize: 12.5, color: _kText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final p = _dipilih!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 4, backgroundColor: _kGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kText),
                    children: [
                      const TextSpan(text: '1 Kategori Dipilih: '),
                      TextSpan(
                        text: '${p.nama} (Rp${_rupiah(p.harga)}/${p.satuan})',
                        style: const TextStyle(color: _kGreenMid),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _dipilih = null),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text('Ubah',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextGray)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: _kGreenMid,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _lanjut,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lanjutkan ke Formulir Antrean',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JenisCard extends StatelessWidget {
  const _JenisCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final JenisSampahItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _kSelectedBg : Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? _kGreenMid : Colors.transparent,
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : const Color(0xFFE3F1F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, size: 22, color: _kGreen),
                  ),
                  const Spacer(),
                  if (selected)
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: _kGreen,
                      child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _Foto(item: item),
              const SizedBox(height: 10),
              Text(
                item.nama,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _kText),
              ),
              const SizedBox(height: 2),
              Text(
                item.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, height: 1.3, color: _kTextGray),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? _kMint : _kChipGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.hargaLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected ? _kGreen : _kText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Foto kategori. Kalau file asset belum ada, tampil blok warna + ikon.
class _Foto extends StatelessWidget {
  const _Foto({required this.item});

  final JenisSampahItem item;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: item.warna.withValues(alpha: 0.45),
      child: Center(
        child: Icon(item.icon, size: 40, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 84,
        width: double.infinity,
        child: item.fotoAsset == null
            ? placeholder
            : Image.asset(
                item.fotoAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}