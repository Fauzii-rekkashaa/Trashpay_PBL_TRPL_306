import 'package:flutter/material.dart';

// ===== Palet warna bersama untuk halaman Auth =====
const kDarkGreen = Color(0xFF1B5E20);
const kPrimaryGreen = Color(0xFF2E7D32);
const kBadgeGreenBg = Color(0xFFA5D6A7);
const kFieldBg = Color(0xFFEEF1F8);
const kHeaderGradientStart = Color(0xFFE0F2F1);
const kHeaderGradientEnd = Color(0xFFE8F5E9);
const kTabBg = Color(0xFFE3E7F7);
const kTextGray = Color(0xFF757575);
const kTextDark = Color(0xFF1A1A1A);
const kLinkBlue = Color(0xFF1565C0);

/// Header TRASHPAY + badge PLAMO + TPS Resmi + statistik mingguan.
/// Dipakai sama di halaman Login maupun Register.
Widget buildAuthHeader() {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [kHeaderGradientStart, kHeaderGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: kDarkGreen, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.recycling, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('TRASHPAY', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: kBadgeGreenBg, borderRadius: BorderRadius.circular(20)),
                        child: const Text('PLAMO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kDarkGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Ubah Sampah Jadi Berkah & Rupiah', style: TextStyle(fontSize: 13, color: kTextGray)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: const Column(
                children: [
                  Icon(Icons.verified_user, color: kPrimaryGreen, size: 16),
                  SizedBox(height: 2),
                  Text('TPS\nResmi', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: kTextDark, height: 1.1)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Icon(Icons.autorenew, color: kPrimaryGreen, size: 18),
              const SizedBox(width: 8),
              const Text('Terkumpul pekan ini: ', style: TextStyle(fontSize: 13, color: kTextGray)),
              const Text('1.240 kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kDarkGreen)),
              const Spacer(),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle)),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Tab switcher Masuk / Daftar Warga.
/// [activeTab] diisi 'login' atau 'register' untuk menentukan tab mana yang disorot.
Widget buildAuthTabSwitcher({
  required String activeTab,
  required VoidCallback onTapLogin,
  required VoidCallback onTapRegister,
}) {
  final isLogin = activeTab == 'login';

  Widget tabContent({required bool active, required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: active ? kDarkGreen : kTextGray),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 15, color: active ? kDarkGreen : kTextGray, fontWeight: active ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget activeCard(Widget child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: child,
      );

  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(color: kTabBg, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTapLogin,
            child: isLogin
                ? activeCard(tabContent(active: true, icon: Icons.login, label: 'Masuk'))
                : tabContent(active: false, icon: Icons.login, label: 'Masuk'),
          ),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTapRegister,
            child: !isLogin
                ? activeCard(tabContent(active: true, icon: Icons.badge_outlined, label: 'Daftar Warga'))
                : tabContent(active: false, icon: Icons.badge_outlined, label: 'Daftar Warga'),
          ),
        ),
      ],
    ),
  );
}

/// Catatan keamanan data, dipakai di bawah form Login maupun Register.
Widget buildSecurityNote() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.lock_clock_outlined, size: 18, color: kTextGray),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          'Data terenkripsi sesuai standar Bank Sampah Nasional & dikelola bersama Pengurus Lingkungan Plamo Garden.',
          style: TextStyle(fontSize: 11.5, color: kTextGray.withOpacity(0.9), height: 1.4),
        ),
      ),
    ],
  );
}

/// Footer bantuan kontak sekretariat.
Widget buildFooterHelp({VoidCallback? onTapHubungi}) {
  return Column(
    children: [
      const Text('Butuh bantuan petugas TPS Plamo Garden?', style: TextStyle(fontSize: 12.5, color: kTextGray)),
      const SizedBox(height: 4),
      InkWell(
        onTap: onTapHubungi,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_in_talk_outlined, size: 15, color: kLinkBlue),
            SizedBox(width: 6),
            Text('Hubungi Sekretariat Bank Sampah RW 08', style: TextStyle(fontSize: 12.5, color: kLinkBlue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ],
  );
}

/// Label field dengan tanda wajib (*) dan hint opsional di kanan.
Widget buildFieldLabel(String text, {bool required = false, String? hint, bool hintGreen = false, Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: kTextDark)),
        if (required) const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing != null) trailing,
        if (hint != null)
          Text(hint, style: TextStyle(fontSize: 11.5, color: hintGreen ? kPrimaryGreen : kTextGray, fontWeight: hintGreen ? FontWeight.bold : FontWeight.normal)),
      ],
    ),
  );
}

/// Input field bergaya seragam (ikon + placeholder + optional suffix).
Widget buildAuthField({
  required TextEditingController controller,
  required IconData icon,
  required String placeholder,
  TextInputType? keyboardType,
  bool obscureText = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    onChanged: onChanged,
    style: const TextStyle(fontSize: 14, color: kTextDark),
    decoration: InputDecoration(
      filled: true,
      fillColor: kFieldBg,
      hintText: placeholder,
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: kTextGray),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    ),
  );
}