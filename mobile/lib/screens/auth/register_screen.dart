import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'auth_shared_widgets.dart'; // kDarkGreen, kTextDark, kTextGray
import 'login_screen.dart';

// Warna tambahan khusus layar ini (sesuai desain Pendaftaran Warga Baru).
const Color _kBg = Color(0xFFF3F8FE);
const Color _kField = Color(0xFFE8F3FC);
const Color _kInfoBg = Color(0xFFE3F1FC);
const Color _kMint = Color(0xFF9BF0A8);
const Color _kHint = Color(0xFF8C9A93);
const Color _kError = Color(0xFFC62828);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _setujuSyarat = false;
  bool _showSetujuError = false;
  bool _isLoading = false;
  String? _errorMessage;

  /// Pesan validasi dari server (422) per kolom: name, nik, email, no_hp, alamat, password.
  Map<String, String> _serverErrors = {};

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ---------- helper ----------

  /// 0812-7098-4321 / +62 812... / 62812... -> 081270984321
  String _normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) digits = '0${digits.substring(2)}';
    return digits;
  }

  void _clearServerError(String key) {
    if (_serverErrors.containsKey(key)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(key));
    }
  }

  /// Ambil pesan error per kolom dari respons server (bentuk Laravel 422).
  /// Aman dipakai untuk Dio maupun exception lain (kalau tidak ada response -> kosong).
  Map<String, String> _parseServerErrors(Object e) {
    final result = <String, String>{};
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map && data['errors'] is Map) {
        (data['errors'] as Map).forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            result[key.toString()] = value.first.toString();
          }
        });
      }
    } catch (_) {}
    return result;
  }

  // ---------- validator ----------

  String? _vNama(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Nama lengkap wajib diisi';
    if (t.length < 3) return 'Nama terlalu pendek';
    return _serverErrors['name'];
  }

  String? _vNik(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'NIK wajib diisi';
    if (t.length != 16) return 'NIK harus 16 digit';
    return _serverErrors['nik'];
  }

  String? _vEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
      return 'Format email tidak valid';
    }
    return _serverErrors['email'];
  }

  String? _vNoHp(String? v) {
    final t = _normalizePhone(v ?? '');
    if (t.isEmpty) return 'Nomor WhatsApp wajib diisi';
    if (!RegExp(r'^08[0-9]{8,11}$').hasMatch(t)) {
      return 'Gunakan nomor Indonesia, contoh 0812xxxxxxxx';
    }
    return _serverErrors['no_hp'];
  }

  String? _vAlamat(String? v) {
    if ((v ?? '').trim().isEmpty) return 'Alamat rumah wajib diisi';
    return _serverErrors['alamat'];
  }

  String? _vPassword(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return 'Kata sandi wajib diisi';
    if (t.length < 8) return 'Kata sandi minimal 8 karakter';
    if (!RegExp(r'[A-Za-z]').hasMatch(t) || !RegExp(r'[0-9]').hasMatch(t)) {
      return 'Harus mengandung huruf dan angka';
    }
    return _serverErrors['password'];
  }

  String? _vKonfirmasi(String? v) {
    if ((v ?? '').isEmpty) return 'Ulangi kata sandi';
    if (v != _passwordController.text) return 'Kata sandi tidak cocok';
    return null;
  }

  // ---------- submit ----------

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _serverErrors = {};
      _errorMessage = null;
    });

    final formOk = _formKey.currentState!.validate();
    if (!_setujuSyarat) setState(() => _showSetujuError = true);
    if (!formOk || !_setujuSyarat) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.register({
        'name': _namaController.text.trim(),
        'nik': _nikController.text.trim(),
        'email': _emailController.text.trim(),
        'no_hp': _normalizePhone(_noHpController.text),
        'alamat': _alamatController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _konfirmasiController.text,
        'role': 'warga',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Akun kamu sedang menunggu verifikasi Pengurus.'),
          backgroundColor: kDarkGreen,
        ),
      );

      _goToLogin();
    } catch (e) {
      if (!mounted) return;
      final fieldErrors = _parseServerErrors(e);
      setState(() {
        _serverErrors = fieldErrors;
        _errorMessage = fieldErrors.isEmpty
            ? 'Pendaftaran gagal. Periksa koneksi dan data kamu, lalu coba lagi.'
            : 'Beberapa data belum valid. Periksa kolom yang ditandai.';
      });
      if (fieldErrors.isNotEmpty) _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _HeroBanner(),
                    const SizedBox(height: 20),
                    _buildFormCard(),
                    const SizedBox(height: 20),
                    const _IncentiveInfo(),
                    const SizedBox(height: 22),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: _goToLogin),
          const Expanded(
            child: Text(
              'Pendaftaran Warga Baru',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kTextDark),
            ),
          ),
          const _CircleIconButton(icon: Icons.eco_outlined),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledField(
              label: 'Nama Lengkap (Sesuai KTP)',
              tag: 'Wajib',
              tagColor: kDarkGreen,
              controller: _namaController,
              hint: 'Nama lengkap',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: _vNama,
              onChanged: (_) => _clearServerError('name'),
            ),
            _LabeledField(
              label: 'NIK / No. Identitas Warga',
              tag: '16 Digit',
              tagColor: kTextGray,
              controller: _nikController,
              hint: '16 digit NIK',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              validator: _vNik,
              onChanged: (_) => _clearServerError('nik'),
            ),
            _LabeledField(
              label: 'Email Aktif',
              controller: _emailController,
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: _vEmail,
              onChanged: (_) => _clearServerError('email'),
            ),
            _LabeledField(
              label: 'Nomor WhatsApp / Telepon',
              tag: 'Notifikasi Jemput',
              tagColor: kDarkGreen,
              controller: _noHpController,
              hint: '0812-3456-7890',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
                LengthLimitingTextInputFormatter(20),
              ],
              validator: _vNoHp,
              onChanged: (_) => _clearServerError('no_hp'),
            ),
            _LabeledField(
              label: 'Alamat Rumah (Blok & No. Rumah)',
              controller: _alamatController,
              hint: 'Perumahan Plamo Garden Blok C3 No. 5',
              icon: Icons.location_on_outlined,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
              validator: _vAlamat,
              onChanged: (_) => _clearServerError('alamat'),
            ),
            _LabeledField(
              label: 'Kata Sandi',
              controller: _passwordController,
              hint: 'Minimal 8 karakter (huruf & angka)',
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePassword,
              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              validator: _vPassword,
              onChanged: (_) => _clearServerError('password'),
            ),
            _LabeledField(
              label: 'Konfirmasi Kata Sandi',
              controller: _konfirmasiController,
              hint: 'Ulangi kata sandi',
              icon: Icons.verified_user_outlined,
              obscure: _obscureKonfirmasi,
              onToggleObscure: () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
              textInputAction: TextInputAction.done,
              validator: _vKonfirmasi,
              onSubmitted: (_) => _handleRegister(),
              isLast: true,
            ),
            const SizedBox(height: 6),
            _buildAgreement(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: _kError, fontSize: 12.5),
                ),
              ),
            const SizedBox(height: 18),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreement() {
    const base = TextStyle(fontSize: 13, height: 1.45, color: kTextDark);
    const link = TextStyle(
      fontSize: 13,
      height: 1.45,
      fontWeight: FontWeight.w700,
      color: kDarkGreen,
    );
    final borderColor = (_showSetujuError && !_setujuSyarat) ? _kError : kDarkGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() {
            _setujuSyarat = !_setujuSyarat;
            if (_setujuSyarat) _showSetujuError = false;
          }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: _setujuSyarat ? kDarkGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: _setujuSyarat
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    style: base,
                    children: [
                      TextSpan(text: 'Saya menyetujui '),
                      TextSpan(text: 'Ketentuan Layanan', style: link),
                      TextSpan(text: ' & '),
                      TextSpan(text: 'Kebijakan Pemilahan Sampah', style: link),
                      TextSpan(text: ' Lingkungan RT 04 / RW 08.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showSetujuError && !_setujuSyarat)
          const Padding(
            padding: EdgeInsets.only(left: 36, top: 6),
            child: Text(
              'Centang persetujuan ketentuan sebelum mendaftar',
              style: TextStyle(fontSize: 12, color: _kError),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kDarkGreen.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          elevation: 4,
          shadowColor: kDarkGreen.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Daftar Menjadi Nasabah',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Sudah punya akun? ',
            style: TextStyle(fontSize: 13.5, color: kTextGray)),
        GestureDetector(
          onTap: _goToLogin,
          child: const Text(
            'Masuk di sini',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: kDarkGreen,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// Komponen khusus layar ini
// =====================================================================

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kInfoBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: kDarkGreen),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: kDarkGreen,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Stack(
          children: [
            Positioned(
              right: -36,
              bottom: -44,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 14),
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 6,
              child: Icon(Icons.water_drop_rounded,
                  size: 64, color: Colors.white.withValues(alpha: 0.18)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.recycling_rounded, size: 15, color: _kMint),
                      SizedBox(width: 6),
                      Text(
                        'RT 04 / RW 08 PLAMO GARDEN',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                          color: _kMint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Registrasi Nasabah Bank\nSampah',
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: Text(
                    'Lengkapi data kependudukan untuk aktivasi buku tabungan sampah digital RT 04 / RW 08.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Color(0xFFD7EBD9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IncentiveInfo extends StatelessWidget {
  const _IncentiveInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kInfoBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _kMint,
            child: Icon(Icons.savings_rounded, color: kDarkGreen, size: 26),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insentif Saldo Digital Otomatis',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Setiap kilogram sampah anorganik terpilah akan otomatis terkonversi ke saldo kas warga.',
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: kTextDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.tag,
    this.tagColor,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isLast = false,
  });

  final String label;
  final String? tag;
  final Color? tagColor;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isLast;

  OutlineInputBorder _border(Color color, [double width = 0]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                ),
                if (tag != null)
                  Text(
                    tag!,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: tagColor ?? kTextGray,
                    ),
                  ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 15, color: kTextDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _kHint, fontSize: 15),
              filled: true,
              fillColor: _kField,
              prefixIcon: Icon(icon, color: kTextGray, size: 22),
              suffixIcon: onToggleObscure == null
                  ? null
                  : IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: kTextGray,
                        size: 22,
                      ),
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              border: _border(Colors.transparent),
              enabledBorder: _border(Colors.transparent),
              focusedBorder: _border(kDarkGreen, 1.6),
              errorBorder: _border(_kError, 1.2),
              focusedErrorBorder: _border(_kError, 1.6),
              errorStyle: const TextStyle(fontSize: 12, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}