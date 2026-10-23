import 'package:flutter/material.dart';


const Color _kGreen = Color(0xFF1B5E20);
const Color _kGreenMid = Color(0xFF2E7D32);
const Color _kGreenDark = Color(0xFF0F5F1E);
const Color _kMint = Color(0xFF9BF0A8);
const Color _kMintSoft = Color(0xFFD4F5D8);
const Color _kText = Color(0xFF16221B);
const Color _kTextGray = Color(0xFF5E6B64);
const Color _kInfoBg = Color(0xFFDDE8EE);
const Color _kQueueInner = Color(0xFFDCEBF7);
const Color _kAmberBg = Color(0xFFFFE9B8);
const Color _kAmberText = Color(0xFF8A4B00);

// ---------------------------------------------------------------------
// Model data
// ---------------------------------------------------------------------

class TransaksiItem {
  const TransaksiItem({
    required this.judul,
    required this.tanggal,
    required this.detail,
    required this.nominal,
    required this.status,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String judul;
  final String tanggal;
  final String detail;
  final int nominal;
  final String status;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}

class DashboardData {
  const DashboardData({
    required this.nama,
    required this.rtRw,
    required this.saldo,
    required this.tambahanBulanIni,
    required this.totalKg,
    required this.nomorAntreanHariIni,
    required this.statusAntrean,
    required this.jenisAntrean,
    required this.estimasiAntrean,
    required this.nilaiAntrean,
    required this.loket,
    required this.updateTerakhir,
    required this.transaksi,
    required this.fakta,
  });

  final String nama;
  final String rtRw;
  final int saldo;
  final int tambahanBulanIni;
  final double totalKg;
  final String? nomorAntreanHariIni; // null = belum ambil antrean
  final String statusAntrean;
  final String jenisAntrean;
  final String estimasiAntrean;
  final int nilaiAntrean;
  final String loket;
  final String updateTerakhir;
  final List<TransaksiItem> transaksi;
  final String fakta;

  factory DashboardData.dummy({String? nama}) {
    return DashboardData(
      nama: nama ?? 'Fauzii',
      rtRw: 'Warga RT 04 / RW 08',
      saldo: 125000,
      tambahanBulanIni: 12500,
      totalKg: 42.5,
      nomorAntreanHariIni: '#A-14',
      statusAntrean: 'Menunggu Giliran',
      jenisAntrean: 'Plastik PET & Botol Kaca',
      estimasiAntrean: 'Estimasi: ± 3.5 kg • Tunai di Loket',
      nilaiAntrean: 14000,
      loket: 'Loket Penimbangan Bank Sampah',
      updateTerakhir: 'Update 10m lalu',
      transaksi: const [
        TransaksiItem(
          judul: 'Plastik & Kardus Tebal',
          tanggal: '18 Okt 2024',
          detail: '8.2 kg',
          nominal: 35000,
          status: 'Selesai',
          icon: Icons.inventory_2_outlined,
          iconBg: Color(0xFFD4F5D8),
          iconColor: _kGreen,
        ),
        TransaksiItem(
          judul: 'Minyak Jelantah (UCO)',
          tanggal: '12 Okt 2024',
          detail: '5.0 Liter',
          nominal: 45000,
          status: 'Selesai',
          icon: Icons.water_drop_outlined,
          iconBg: Color(0xFFFFE9B8),
          iconColor: Color(0xFFB26A00),
        ),
      ],
      fakta:
          '1 botol plastik butuh hingga 450 tahun untuk terurai secara alami. '
          'Mari terus pilah dari rumah hari ini!',
    );
  }
}

/// 125000 -> "125.000"  (public: dulu ada di beranda_tab.dart, mungkin dipakai file lain)
String formatRupiah(num v) {
  final s = v.round().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

String _rupiah(int v) => 'Rp${formatRupiah(v)}';

// ---------------------------------------------------------------------
// Tab Beranda
// ---------------------------------------------------------------------

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key, this.onSetorTap, this.userName});

  /// Dipanggil saat kartu "Setor Sampah Sekarang" / tombol + ditekan
  /// (biasanya pindah ke tab Setor Sampah).
  final VoidCallback? onSetorTap;

  /// Nama dari respons login. Kalau null dipakai data dummy.
  final String? userName;

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  late DashboardData data;

  @override
  void initState() {
    super.initState();
    // TODO: ganti dengan panggilan API (mis. GET /api/dashboard) setelah backend siap.
    data = DashboardData.dummy(nama: widget.userName);
  }

  void onSoon(String fitur) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$fitur belum tersedia.')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onBell: () => onSoon('Notifikasi')),
          const SizedBox(height: 16),
          const Text(
            'Halo, Selamat Pagi 👋',
            style: TextStyle(fontSize: 14, color: _kText),
          ),
          const SizedBox(height: 2),
          Text(
            data.nama,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.rtRw,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kGreen,
            ),
          ),
          const SizedBox(height: 16),
          _SaldoCard(
            data: data,
            onTarik: () => onSoon('Tarik saldo'),
            onRiwayat: () => onSoon('Riwayat'),
          ),
          const SizedBox(height: 18),
          _SetorCard(
            onTap: widget.onSetorTap ?? () => onSoon('Setor sampah'),
          ),
          const SizedBox(height: 22),
          _SectionTitle(
            icon: Icons.confirmation_number_outlined,
            title: 'Status Antrean Penimbangan',
            trailing: data.updateTerakhir,
          ),
          const SizedBox(height: 10),
          _AntreanCard(data: data, onCek: () => onSoon('Cek posisi')),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaksi Terakhir',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
              ),
              InkWell(
                onTap: () => onSoon('Daftar transaksi'),
                child: const Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _kGreen,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        size: 16, color: _kGreen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final t in data.transaksi) ...[
            _TransaksiTile(item: t),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          _FaktaCard(teks: data.fakta),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBell});

  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TrashPay',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                ),
              ),
              Text(
                'PLAMO GARDEN',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: _kGreenMid,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: onBell,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.notifications_none_rounded,
                size: 26, color: _kText),
          ),
        ),
        const SizedBox(width: 6),
        // TODO: ganti dengan foto profil (NetworkImage) bila sudah ada.
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFDCE9F2),
          child: Icon(Icons.person_rounded, size: 20, color: _kTextGray),
        ),
      ],
    );
  }
}

class _SaldoCard extends StatelessWidget {
  const _SaldoCard({
    required this.data,
    required this.onTarik,
    required this.onRiwayat,
  });

  final DashboardData data;
  final VoidCallback onTarik;
  final VoidCallback onRiwayat;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [_kGreenMid, _kGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGreenDark.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi daun
          Positioned(
            right: -24,
            top: -10,
            child: Icon(Icons.eco_rounded,
                size: 120, color: Colors.white.withValues(alpha: 0.10)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 17, color: Colors.white),
                    const SizedBox(width: 6),
                    const Text(
                      'Saldo Kas Sampah',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bayar Tunai di Loket',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _rupiah(data.saldo),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+${_rupiah(data.tambahanBulanIni)} bln ini',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _kMint,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _CardButton(
                        label: 'Tarik Saldo',
                        icon: Icons.payments_outlined,
                        filled: true,
                        onTap: onTarik,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CardButton(
                        label: 'Riwayat',
                        icon: Icons.history_rounded,
                        filled: false,
                        onTap: onRiwayat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.white.withValues(alpha: 0.25), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.hourglass_bottom_rounded,
                        label: 'Terkumpul',
                        value: '${data.totalKg} kg',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.format_list_numbered_rounded,
                        label: 'Antrean Hari Ini',
                        value: data.nomorAntreanHariIni == null
                            ? 'Belum ada'
                            : 'Antrean ${data.nomorAntreanHariIni}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? _kGreen : Colors.white;
    return Material(
      color: filled ? Colors.white : Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetorCard extends StatelessWidget {
  const _SetorCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _kMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.recycling_rounded,
                    size: 30, color: _kGreen),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Setor Sampah Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _kText,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        CircleAvatar(radius: 4, backgroundColor: _kGreenMid),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Ambil nomor antrean setor sampah',
                      style: TextStyle(fontSize: 12.5, color: _kTextGray),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: _kGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded,
                    size: 26, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: _kGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: _kTextGray,
          ),
        ),
      ],
    );
  }
}

class _AntreanCard extends StatelessWidget {
  const _AntreanCard({required this.data, required this.onCek});

  final DashboardData data;
  final VoidCallback onCek;

  @override
  Widget build(BuildContext context) {
    final punyaAntrean = data.nomorAntreanHariIni != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: punyaAntrean
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '#',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nomor Antrean ${data.nomorAntreanHariIni}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _kAmberBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hourglass_bottom_rounded,
                              size: 13, color: _kAmberText),
                          const SizedBox(width: 4),
                          Text(
                            data.statusAntrean,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _kAmberText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kQueueInner,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.hourglass_empty_rounded,
                            size: 24, color: _kTextGray),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.jenisAntrean,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.estimasiAntrean,
                              style: const TextStyle(
                                  fontSize: 12, color: _kTextGray),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '~${_rupiah(data.nilaiAntrean)}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _kGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 17, color: _kTextGray),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.loket,
                        style: const TextStyle(fontSize: 12.5, color: _kTextGray),
                      ),
                    ),
                    InkWell(
                      onTap: onCek,
                      child: const Row(
                        children: [
                          Text(
                            'Cek Posisi',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: _kGreen,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: _kGreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada antrean hari ini. Ketuk "Setor Sampah Sekarang" untuk mengambil nomor.',
                style: TextStyle(fontSize: 13, height: 1.4, color: _kTextGray),
              ),
            ),
    );
  }
}

class _TransaksiTile extends StatelessWidget {
  const _TransaksiTile({required this.item});

  final TransaksiItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, size: 26, color: item.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.tanggal} • ${item.detail}',
                  style: const TextStyle(fontSize: 12, color: _kTextGray),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${_rupiah(item.nominal)}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _kGreen,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _kMintSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _kGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaktaCard extends StatelessWidget {
  const _FaktaCard({required this.teks});

  final String teks;

  @override
  Widget build(BuildContext context) {
    const hl = '450 tahun';
    final i = teks.indexOf(hl);
    final spans = <TextSpan>[];
    if (i >= 0) {
      spans.add(TextSpan(text: teks.substring(0, i)));
      spans.add(const TextSpan(
        text: hl,
        style: TextStyle(color: _kGreenMid, fontWeight: FontWeight.w700),
      ));
      spans.add(TextSpan(text: teks.substring(i + hl.length)));
    } else {
      spans.add(TextSpan(text: teks));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kInfoBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kAmberBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                size: 22, color: _kAmberText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TAHUKAH ANDA?',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w900,
                    color: _kAmberText,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: _kText,
                    ),
                    children: spans,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.recycling_rounded,
              size: 44, color: Colors.white.withValues(alpha: 0.55)),
        ],
      ),
    );
  }
}