import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/auth_shared_widgets.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class _MiniCardData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _MiniCardData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPageData {
  final int langkah;
  final String imageAsset;
  final IconData fallbackIcon;
  final String chipText;
  final _MiniCardData kiri;
  final _MiniCardData kanan;
  final String judul;
  final String deskripsi;

  const _OnboardingPageData({
    required this.langkah,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.chipText,
    required this.kiri,
    required this.kanan,
    required this.judul,
    required this.deskripsi,
  });
}

const _pages = <_OnboardingPageData>[
  _OnboardingPageData(
    langkah: 1,
    imageAsset: 'assets/images/onboarding_1.png',
    fallbackIcon: Icons.recycling,
    chipText: 'Organik • Plastik • Logam',
    kiri: _MiniCardData(
      icon: Icons.eco,
      iconBg: Color(0xFFA7F3D0),
      iconColor: kDarkGreen,
      title: 'Organik',
      subtitle: 'Pupuk kompos',
    ),
    kanan: _MiniCardData(
      icon: Icons.recycling,
      iconBg: Color(0xFFBBDEFB),
      iconColor: kLinkBlue,
      title: 'Anorganik',
      subtitle: 'Bernilai tunai',
    ),
    judul: 'Pilah Sampahmu',
    deskripsi:
        'Pisahkan sampah berdasarkan jenisnya untuk membantu menjaga kelestarian lingkungan dan mempermudah kalkulasi reward.',
  ),
  _OnboardingPageData(
    langkah: 2,
    imageAsset: 'assets/images/onboarding_2.png',
    fallbackIcon: Icons.confirmation_number_outlined,
    chipText: 'Kuota per jadwal',
    kiri: _MiniCardData(
      icon: Icons.confirmation_number_outlined,
      iconBg: Color(0xFFA7F3D0),
      iconColor: kDarkGreen,
      title: 'Antrean',
      subtitle: 'Tertib, tidak menumpuk',
    ),
    kanan: _MiniCardData(
      icon: Icons.event_available,
      iconBg: Color(0xFFBBDEFB),
      iconColor: kLinkBlue,
      title: 'Jadwal',
      subtitle: 'Sesuai kuota TPS',
    ),
    judul: 'Ambil Antrean & Setor',
    deskripsi:
        'Daftar antrean pada jadwal penyetoran yang tersedia, lalu bawa sampah terpilah ke TPS Plamo Garden sesuai nomor antreanmu.',
  ),
  _OnboardingPageData(
    langkah: 3,
    imageAsset: 'assets/images/onboarding_3.png',
    fallbackIcon: Icons.scale_outlined,
    chipText: 'Transparan • Tercatat',
    kiri: _MiniCardData(
      icon: Icons.scale_outlined,
      iconBg: Color(0xFFA7F3D0),
      iconColor: kDarkGreen,
      title: 'Timbang',
      subtitle: 'Diperiksa petugas',
    ),
    kanan: _MiniCardData(
      icon: Icons.account_balance_wallet_outlined,
      iconBg: Color(0xFFBBDEFB),
      iconColor: kLinkBlue,
      title: 'Saldo',
      subtitle: 'Masuk dompet digital',
    ),
    judul: 'Timbang & Terima Saldo',
    deskripsi:
        'Petugas menimbang dan memeriksa sampahmu, lalu nilainya otomatis tercatat sebagai saldo yang bisa kamu pantau dan ajukan penarikannya.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _storage = const FlutterSecureStorage();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish({bool toRegister = false}) async {
    await _storage.write(key: 'onboarding_done', value: 'true');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => toRegister ? const RegisterScreen() : const LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish(toRegister: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(isLast),
              const SizedBox(height: 14),
              _buildTagline(),
              const SizedBox(height: 18),
              _buildPagerCard(),
              const SizedBox(height: 18),
              _buildStats(),
              const SizedBox(height: 20),
              _buildPrimaryButton(isLast),
              const SizedBox(height: 14),
              _buildLoginLink(),
              const SizedBox(height: 18),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TOP BAR ----------------
  Widget _buildTopBar(bool isLast) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: kDarkGreen, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.recycling, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('TRASHPAY', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: kDarkGreen)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF9DF5CF), borderRadius: BorderRadius.circular(20)),
                    child: const Text('TPS PLAMO', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: kDarkGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text('Plamo Garden Eco-Waste Hub', style: TextStyle(fontSize: 12, color: kTextGray, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Visibility(
          visible: !isLast,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _finish(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: kTabBg, borderRadius: BorderRadius.circular(20)),
              child: const Text('Lewati', style: TextStyle(color: kLinkBlue, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- TAGLINE ----------------
  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFEEF1FB), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.eco, color: kPrimaryGreen, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('“Buang Sampah, Dapat Rupiah”',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: kTextDark)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFD6EFE6), borderRadius: BorderRadius.circular(20)),
            child: const Text('Verified 100%', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: kDarkGreen)),
          ),
        ],
      ),
    );
  }

  // ---------------- PAGER CARD ----------------
  Widget _buildPagerCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAFBF3), Colors.white, Color(0xFFE9F2FF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 430,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _buildPage(_pages[i]),
            ),
          ),
          const SizedBox(height: 4),
          _buildDots(),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData p) {
    return Column(
      children: [
        _buildHero(p),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMiniCard(p.kiri)),
            const SizedBox(width: 12),
            Expanded(child: _buildMiniCard(p.kanan)),
          ],
        ),
        const SizedBox(height: 18),
        Text(p.judul, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            p.deskripsi,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: kTextGray, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(_OnboardingPageData p) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 1.9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Kalau gambar belum ditaruh di assets, otomatis tampil gradient hijau + ikon (app tidak crash)
            Image.asset(
              p.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryGreen, kDarkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(p.fallbackIcon, size: 64, color: Colors.white.withValues(alpha: 0.85)),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: kDarkGreen, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.checklist_rtl, size: 15, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('Langkah ${p.langkah}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        p.chipText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(_MiniCardData d) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFEEF1FB), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: d.iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(d.icon, size: 20, color: d.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: kTextDark)),
                Text(d.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: kTextGray, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 36 : 12,
          height: 8,
          decoration: BoxDecoration(
            color: active ? kDarkGreen : const Color(0xFFB9CBC3),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  // ---------------- STATS ----------------
  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: _statCard('1.2+ Ton', 'Sampah Terolah', kPrimaryGreen)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Rp 14.8 Jt', 'Cair ke Warga', kLinkBlue)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('350+ KK', 'Warga Aktif', kTextDark)),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: kTextGray, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------------- BUTTON & LINKS ----------------
  Widget _buildPrimaryButton(bool isLast) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkGreen,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isLast ? 'Mulai Sekarang' : 'Lanjut',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 19),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Sudah punya akun?  ', style: TextStyle(fontSize: 14, color: kTextGray)),
        InkWell(
          onTap: () => _finish(),
          child: const Text('Masuk', style: TextStyle(fontSize: 14, color: kLinkBlue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 15, color: kTextGray),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Inisiatif Mandiri Komunitas RT/RW Plamo Garden',
            style: TextStyle(fontSize: 11.5, color: kTextGray, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}