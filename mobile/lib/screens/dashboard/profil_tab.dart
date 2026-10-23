import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';



const Color _kGreen = Color(0xFF1B5E20);
const Color _kGreenMid = Color(0xFF2E7D32);
const Color _kMint = Color(0xFF9BF0A8);
const Color _kText = Color(0xFF16221B);
const Color _kTextGray = Color(0xFF5E6B64);
const Color _kBg = Color(0xFFF1F6FF);
const Color _kRed = Color(0xFFC62828);

class ProfilData {
  const ProfilData({
    required this.nama,
    required this.status,
    required this.idWarga,
    required this.nik,
    required this.noHp,
    required this.email,
    required this.alamat,
    required this.kgDisetor,
    required this.pohon,
    required this.level,
    required this.nikTerverifikasi,
  });

  final String nama;
  final String status;
  final String idWarga;
  final String nik;
  final String noHp;
  final String email;
  final String alamat;
  final double kgDisetor;
  final int pohon;
  final String level;
  final bool nikTerverifikasi;

  // DUMMY
  static const dummy = ProfilData(
    nama: 'Fauzii',
    status: 'Warga Aktif RT 04 / RW 08',
    idWarga: 'W-PLM-04-0182',
    nik: '2171012803950002',
    noHp: '0812-7098-4321',
    email: 'Fauzii@gmail.com',
    alamat: 'Perumahan Plamo Garden Blok C3 No. 14, Batam Center',
    kgDisetor: 112.5,
    pohon: 6,
    level: 'Pahlawan Hijau',
    nikTerverifikasi: true,
  );
}

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key, this.onBack});

  /// Panah kembali (biasanya pindah ke Beranda).
  final VoidCallback? onBack;

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  final ApiService _api = ApiService();
  bool _loading = false;

  // TODO: ganti dengan data dari GET /api/user.
  final ProfilData _data = ProfilData.dummy;

  Future<void> _keluar() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu harus masuk lagi untuk memakai TrashPay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    setState(() => _loading = true);
    await _api.logout(); // hapus token di server + di HP (aman walau server gagal)
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _belumAda(String nama) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$nama belum tersedia.')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _topBar(),
            const SizedBox(height: 10),
            _resmiRow(),
            const SizedBox(height: 14),
            _kartuProfil(),
            const SizedBox(height: 14),
            _kartuDampak(),
            const SizedBox(height: 20),
            _judulData(),
            const SizedBox(height: 10),
            _kartuData(),
            const SizedBox(height: 20),
            const Text('Layanan & Bantuan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kText)),
            const SizedBox(height: 10),
            _kartuLayanan(),
            const SizedBox(height: 16),
            _tombolKeluar(),
            const SizedBox(height: 18),
            _footer(),
          ],
        ),
      ),
    );
  }

  // ---------- bagian-bagian ----------

  Widget _topBar() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: _kText),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLAMO GARDEN',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _kGreenMid)),
                Text('Profil Warga',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _kText)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _belumAda('Notifikasi'),
            icon: const Icon(Icons.notifications_none_rounded, color: _kText),
          ),
        ],
      ),
    );
  }

  Widget _resmiRow() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 17,
          backgroundColor: _kMint,
          child: Icon(Icons.verified_user_outlined, size: 18, color: _kGreen),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('PROFIL WARGA RESMI',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: _kGreen)),
        ),
        Material(
          color: const Color(0xFFDCE9F2),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _belumAda('Pengaturan'),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.settings_outlined, size: 21, color: _kText),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _kartu() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );

  Widget _kartuProfil() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
      decoration: _kartu(),
      child: Column(
        children: [
          SizedBox(
            width: 104,
            height: 104,
            child: Stack(
              children: [
                // TODO: ganti dengan foto profil dari server (NetworkImage).
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDCE9F2),
                    border: Border.all(color: _kGreenMid, width: 3),
                  ),
                  child: const Icon(Icons.person_rounded, size: 56, color: _kTextGray),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Material(
                    color: _kGreen,
                    shape: const CircleBorder(
                        side: BorderSide(color: Colors.white, width: 2)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _belumAda('Ganti foto'),
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(Icons.photo_camera_outlined,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(_data.nama,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: _kText)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _kMint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 4, backgroundColor: _kGreen),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(_data.status,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _kGreen)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('ID: ${_data.idWarga}',
              style: const TextStyle(fontSize: 11.5, color: _kTextGray)),
        ],
      ),
    );
  }

  Widget _kartuDampak() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, size: 20, color: Color(0xFFFFD54F)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('Dampak Lingkungan',
                    style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('MUSIM 2024',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statBox(Icons.workspace_premium_outlined, _data.level,
                    'Tingkat 3', kecil: true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox(Icons.hourglass_bottom_rounded,
                    _data.kgDisetor.toString(), 'Kg Disetor'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox(Icons.park_rounded, '${_data.pohon}', 'Pohon Lestari'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(IconData icon, String nilai, String label, {bool kecil = false}) {
    return Container(
      height: 116,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(icon, size: 17, color: _kMint),
          ),
          const SizedBox(height: 8),
          Text(nilai,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: kecil ? 11.5 : 21,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10.5, color: Colors.white.withValues(alpha: 0.75))),
        ],
      ),
    );
  }

  Widget _judulData() {
    return const Row(
      children: [
        Expanded(
          child: Text('Data Kependudukan & Akun',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kText)),
        ),
        Icon(Icons.check_circle_outline_rounded, size: 15, color: _kGreenMid),
        SizedBox(width: 4),
        Text('RT 04 Siap Layani',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: _kGreenMid)),
      ],
    );
  }

  Widget _kartuData() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: _kartu(),
      child: Column(
        children: [
          _barisData(Icons.badge_outlined, 'Nama Lengkap', _data.nama),
          _barisData(
            Icons.fingerprint_rounded,
            'Nomor Induk Kependudukan (NIK)',
            _data.nik,
            badge: _data.nikTerverifikasi ? 'Terverifikasi RT' : null,
          ),
          _barisData(Icons.phone_outlined, 'Nomor WhatsApp', _data.noHp),
          _barisData(Icons.mail_outline_rounded, 'Alamat Email', _data.email,
              nilaiBold: false),
          _barisData(Icons.location_on_outlined, 'Alamat Domisili', _data.alamat,
              nilaiBold: false, terakhir: true),
        ],
      ),
    );
  }

  Widget _barisData(
    IconData icon,
    String label,
    String nilai, {
    String? badge,
    bool nilaiBold = true,
    bool terakhir = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: terakhir ? 4 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 21, color: _kGreenMid),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: _kTextGray)),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(nilai,
                        style: TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: nilaiBold ? FontWeight.w800 : FontWeight.w500,
                            color: _kText)),
                    if (badge != null)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kMint.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded,
                                size: 13, color: _kGreen),
                            const SizedBox(width: 4),
                            Text(badge,
                                style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: _kGreen)),
                          ],
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

  Widget _kartuLayanan() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: _kartu(),
      child: Column(
        children: [
          _itemLayanan(Icons.account_balance_wallet_outlined,
              'Catatan Setoran & Pembayaran Tunai',
              'Cek mutasi rupiah dan akumulasi gram',
              hijau: true),
          _itemLayanan(Icons.local_shipping_outlined,
              'Jadwal Buka Loket & Antrean Poskoling',
              'Selasa & Sabtu, jam 08:30 WIB'),
          _itemLayanan(Icons.support_agent_rounded,
              'Bantuan & Pengurus Bank Sampah',
              'Ketua RT 04 & Koordinator Daur Ulang'),
          _itemLayanan(Icons.privacy_tip_outlined, 'Syarat, Ketentuan & Privasi',
              'Prosedur penimbangan & keamanan data'),
        ],
      ),
    );
  }

  Widget _itemLayanan(IconData icon, String judul, String sub, {bool hijau = false}) {
    return InkWell(
      onTap: () => _belumAda(judul),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: hijau ? const Color(0xFFD7F5E6) : const Color(0xFFDCE9F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 23, color: hijau ? _kGreen : _kTextGray),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w800, color: _kText)),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _kTextGray)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _kTextGray),
          ],
        ),
      ),
    );
  }

  Widget _tombolKeluar() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: _loading ? null : _keluar,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: _kRed),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout_rounded, size: 20, color: _kRed),
                      SizedBox(width: 8),
                      Text('Keluar dari Akun',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _kRed)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return const Column(
      children: [
        Text('PLAMO GARDEN ECO-WASTE v2.4.0',
            style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: _kTextGray)),
        SizedBox(height: 4),
        Text('Kolaborasi Gotong Royong Warga • PBL Part-2 Universitas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: _kTextGray)),
      ],
    );
  }
}