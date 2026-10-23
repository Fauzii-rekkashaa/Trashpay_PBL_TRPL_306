import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'auth_shared_widgets.dart'; // kDarkGreen, kTextDark, kTextGray
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../dashboard/warga_dashboard_screen.dart';

// Warna tambahan khusus layar ini (sesuai desain Login).
const Color _kBg = Color(0xFFF3F8FE);
const Color _kField = Color(0xFFE8F3FC);
const Color _kChipBg = Color(0xFFE3EEF7);
const Color _kLogoBg = Color(0xFFD9F7DC);
const Color _kQuoteBg = Color(0xFFD4F5D8);
const Color _kMint = Color(0xFF9BF0A8);
const Color _kHint = Color(0xFF8C9A93);
const Color _kError = Color(0xFFC62828);
const Color _kGradStart = Color(0xFF0F5F1E);
const Color _kGradEnd = Color(0xFF2E7D32);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identitasController = TextEditingController(); // email atau no HP
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _obscurePassword = true;
  bool _ingatSaya = false; // TODO: hubungkan ke penyimpanan sesi di ApiService bila dibutuhkan
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identitasController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Email dikirim apa adanya. Nomor HP (0812-7098-4321 / +62812...) dinormalkan ke 0812...
  String _normalizeIdentitas(String raw) {
    final t = raw.trim();
    if (t.contains('@')) return t;
    var digits = t.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return t;
    if (digits.startsWith('62')) digits = '0${digits.substring(2)}';
    return digits;
  }

  /// Pesan dari server untuk kasus tertentu (mis. 403 akun belum diverifikasi).
  /// Aman untuk Dio maupun exception lain.
  String? _serverMessage(Object e) {
    try {
      final res = (e as dynamic).response;
      final code = res?.statusCode;
      final data = res?.data;
      if (code == 403 && data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.login(
        _normalizeIdentitas(_identitasController.text),
        _passwordController.text,
      );

      final token = response.data['token'];
      final user = response.data['user'];
      await _apiService.saveToken(token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang kembali, ${user['name']}!'),
          backgroundColor: kDarkGreen,
        ),
      );

      // TODO: bedakan tujuan sesuai role (warga/petugas/pengurus). Sementara semua ke dashboard warga.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WargaDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _serverMessage(e) ??
            'Masuk gagal. Periksa kembali email/nomor HP dan kata sandi kamu.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _showInfo(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BrandHeader(),
              const SizedBox(height: 22),
              _buildFormCard(),
              const SizedBox(height: 22),
              _buildRegisterLink(),
              const SizedBox(height: 22),
              const _QuoteCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
            const _FieldLabel('Email Warga / No. Telepon'),
            _AuthTextField(
              controller: _identitasController,
              hint: 'contoh: bima.santoso@email.com',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Email atau nomor HP wajib diisi'
                  : null,
            ),
            const SizedBox(height: 18),
            const _FieldLabel('Kata Sandi'),
            _AuthTextField(
              controller: _passwordController,
              hint: 'Masukkan kata sandi',
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _buildRememberRow(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: _kError, fontSize: 12.5),
                ),
              ),
            const SizedBox(height: 18),
            _buildLoginButton(),
            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRememberRow() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _ingatSaya = !_ingatSaya),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _ingatSaya ? kDarkGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kDarkGreen, width: 2),
                ),
                child: _ingatSaya
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              const Text(
                'Ingat Saya',
                style: TextStyle(fontSize: 13, color: kTextDark),
              ),
            ],
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ForgotPasswordScreen(
                initialIdentitas: _identitasController.text,
              ),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kDarkGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Opacity(
      opacity: _isLoading ? 0.7 : 1,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [_kGradStart, _kGradEnd]),
          boxShadow: [
            BoxShadow(
              color: _kGradEnd.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _isLoading ? null : _handleLogin,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.6, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masuk ke Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            size: 20, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.10))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau masuk lebih cepat dengan',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: kTextGray,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.10))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 52,
      child: Material(
        color: _kField,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showInfo('Masuk dengan Google belum tersedia.'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ganti dengan Image.asset('assets/images/google_g.png') bila punya logo resminya.
              Text(
                'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4285F4),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Masuk dengan Google',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Column(
      children: [
        const Text(
          'Belum terdaftar sebagai nasabah bank sampah?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: kTextDark),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _goToRegister,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              'Daftar Sekarang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: kDarkGreen,
              ),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo: ganti isi lingkaran dengan Image.asset('assets/images/logo.png') bila ada.
        SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: _kLogoBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.recycling_rounded,
                    size: 52, color: kDarkGreen),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kDarkGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: _kBg, width: 3),
                  ),
                  child: const Icon(Icons.eco_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _kChipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 4, backgroundColor: kDarkGreen),
              SizedBox(width: 8),
              Text(
                'PLAMO GARDEN ECO-WASTE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w700,
                  color: kDarkGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'TrashPay',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Selamat datang warga! Masuk untuk kelola setoran sampah & pantau saldo insentif Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.45, color: kTextDark),
          ),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kQuoteBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _kMint,
            child: Icon(Icons.eco_outlined, size: 18, color: kDarkGreen),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOTONG ROYONG HIJAU',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
                    color: kDarkGreen,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '“Setiap 1 kg sampah terpilah mengurangi jejak karbon lingkungan kita.”',
                  style: TextStyle(fontSize: 13.5, height: 1.45, color: kTextDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kTextDark,
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  OutlineInputBorder _border(Color color, [double width = 0]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide:
          width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
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
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: kTextGray,
                  size: 22,
                ),
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        border: _border(Colors.transparent),
        enabledBorder: _border(Colors.transparent),
        focusedBorder: _border(kDarkGreen, 1.6),
        errorBorder: _border(_kError, 1.2),
        focusedErrorBorder: _border(_kError, 1.6),
        errorStyle: const TextStyle(fontSize: 12, height: 1.2),
      ),
    );
  }
}