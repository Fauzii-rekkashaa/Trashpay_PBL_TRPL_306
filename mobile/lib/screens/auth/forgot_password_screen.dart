import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'auth_shared_widgets.dart'; // kDarkGreen, kTextDark, kTextGray

// Warna khusus layar ini (sama dengan Login/Register).
const Color _kBg = Color(0xFFF3F8FE);
const Color _kField = Color(0xFFE8F3FC);
const Color _kChipBg = Color(0xFF9BF0A8);
const Color _kRingOuter = Color(0xFFD9F7DC);
const Color _kRingInner = Color(0xFFB9E9C0);
const Color _kSuccessBg = Color(0xFFE3F1F9);
const Color _kHelpBg = Color(0xFFDDE8EE);
const Color _kMint = Color(0xFF9BF0A8);
const Color _kHint = Color(0xFF8C9A93);
const Color _kError = Color(0xFFC62828);
const Color _kGradStart = Color(0xFF0F5F1E);
const Color _kGradEnd = Color(0xFF2E7D32);

/// Lama jeda sebelum tautan boleh dikirim ulang (detik).
/// Samakan dengan `cooldown_seconds` dari backend.
const int _kCooldownSeconds = 60;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialIdentitas});

  /// Opsional: isi otomatis dari kolom email/no. HP di halaman Masuk.
  final String? initialIdentitas;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identitasController = TextEditingController();
  final ApiService _apiService = ApiService();

  Timer? _timer;
  int _secondsLeft = 0;
  bool _isLoading = false;
  bool _sent = false;
  String? _errorMessage;
  String _maskedTarget = '';

  @override
  void initState() {
    super.initState();
    _identitasController.text = widget.initialIdentitas ?? '';
    _identitasController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _identitasController.dispose();
    super.dispose();
  }

  // ---------- Logika ----------

  bool get _cooldownActive => _secondsLeft > 0;

  String get _countdownText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool _isEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

  String _normalizeIdentitas(String raw) {
    final t = raw.trim();
    if (t.contains('@')) return t.toLowerCase();
    var digits = t.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) digits = '0${digits.substring(2)}';
    return digits;
  }

  String? _validate(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email atau nomor WhatsApp wajib diisi';
    if (t.contains('@')) {
      return _isEmail(t) ? null : 'Format email tidak valid';
    }
    final digits = _normalizeIdentitas(t);
    if (digits.length < 9 || digits.length > 15) {
      return 'Nomor WhatsApp tidak valid';
    }
    return null;
  }

  /// bima.santoso@gmail.com -> bima.***@gmail.com ; 081234567890 -> 0812****890
  String _mask(String identitas) {
    if (identitas.contains('@')) {
      final parts = identitas.split('@');
      final local = parts.first;
      final keep = local.length <= 4 ? 1 : 4;
      return '${local.substring(0, keep)}***@${parts.last}';
    }
    if (identitas.length <= 7) return identitas;
    return '${identitas.substring(0, 4)}****${identitas.substring(identitas.length - 3)}';
  }

  void _startCooldown([int seconds = _kCooldownSeconds]) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _handleSend() async {
    FocusScope.of(context).unfocus();
    if (_cooldownActive) return;
    if (!_formKey.currentState!.validate()) return;

    final identitas = _normalizeIdentitas(_identitasController.text);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.forgotPassword(identitas);

      // Backend selalu membalas generik (tidak membocorkan apakah akun ada).
      int cooldown = _kCooldownSeconds;
      try {
        final c = response.data['cooldown_seconds'];
        if (c is int && c > 0) cooldown = c;
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _sent = true;
        _maskedTarget = _mask(identitas);
      });
      _startCooldown(cooldown);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _errorFrom(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _errorFrom(Object e) {
    try {
      final res = (e as dynamic).response;
      if (res?.statusCode == 429) {
        return 'Terlalu banyak permintaan. Coba lagi beberapa menit lagi.';
      }
    } catch (_) {}
    return 'Gagal mengirim tautan. Periksa koneksi internet lalu coba lagi.';
  }

  void _showInfo(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _backToLogin() => Navigator.of(context).maybePop();

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              const SizedBox(height: 22),
              const _HeroIcon(),
              const SizedBox(height: 14),
              const _BrandChip(),
              const SizedBox(height: 16),
              const Text(
                'Lupa Kata Sandi Anda?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'Masukkan alamat email atau nomor WhatsApp yang terdaftar. '
                  'Kami akan mengirimkan tautan verifikasi aman untuk membuat kata sandi baru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.5, height: 1.5, color: kTextGray),
                ),
              ),
              const SizedBox(height: 20),
              _buildFormCard(),
              if (_sent) ...[
                const SizedBox(height: 18),
                _buildSuccessCard(),
              ],
              const SizedBox(height: 18),
              _buildHelpCard(),
              const SizedBox(height: 20),
              _buildBackButton(),
              const SizedBox(height: 12),
              const Text(
                'Kelurahan Plamo Garden • RT 03 / RW 08',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kTextGray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Atur Ulang Sandi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: const Color(0xFFDCE9F2),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _backToLogin,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.arrow_back_rounded,
                      size: 22, color: kTextDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final hasText = _identitasController.text.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            const Row(
              children: [
                Text(
                  'Email Terdaftar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                Spacer(),
                Icon(Icons.verified_user_outlined, size: 15, color: kDarkGreen),
                SizedBox(width: 4),
                Text(
                  'Warga Terverifikasi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kDarkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _identitasController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: _validate,
              onFieldSubmitted: (_) => _handleSend(),
              style: const TextStyle(fontSize: 15, color: kTextDark),
              decoration: InputDecoration(
                hintText: 'contoh: bima.santoso@email.com',
                hintStyle: const TextStyle(color: _kHint, fontSize: 15),
                filled: true,
                fillColor: _kField,
                prefixIcon: const Icon(Icons.mail_outline_rounded,
                    color: kTextGray, size: 22),
                suffixIcon: hasText
                    ? IconButton(
                        onPressed: () {
                          _identitasController.clear();
                          setState(() => _errorMessage = null);
                        },
                        icon: const Icon(Icons.cancel_outlined,
                            color: kTextGray, size: 22),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                border: _border(Colors.transparent),
                enabledBorder: _border(Colors.transparent),
                focusedBorder: _border(kDarkGreen, 1.6),
                errorBorder: _border(_kError, 1.2),
                focusedErrorBorder: _border(_kError, 1.6),
                errorStyle: const TextStyle(fontSize: 12, height: 1.2),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: _kError, fontSize: 12.5),
                ),
              ),
            const SizedBox(height: 16),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, [double width = 0]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
    );
  }

  Widget _buildSendButton() {
    final disabled = _isLoading || _cooldownActive;
    return Opacity(
      opacity: disabled ? 0.65 : 1,
      child: Container(
        height: 54,
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
            onTap: disabled ? null : _handleSend,
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
                        Icon(Icons.send_outlined,
                            size: 19, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Kirim Tautan Reset',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSuccessBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: _kMint,
                child: Icon(Icons.check_circle_rounded,
                    size: 26, color: kDarkGreen),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tautan Berhasil Dikirim!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: kDarkGreen,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _cooldownActive ? 'Aktif' : 'Selesai',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: kDarkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Instruksi reset kata sandi telah dikirim ke $_maskedTarget. '
            'Silakan periksa kotak masuk atau spam dalam 5 menit.',
            style: const TextStyle(fontSize: 13, height: 1.45, color: kTextDark),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 18, color: kTextGray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _cooldownActive
                        ? 'Kirim ulang kode dalam'
                        : 'Belum menerima tautan?',
                    style: const TextStyle(fontSize: 13, color: kTextDark),
                  ),
                ),
                if (_cooldownActive)
                  Text(
                    _countdownText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: kDarkGreen,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  )
                else
                  InkWell(
                    onTap: _isLoading ? null : _handleSend,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Kirim Ulang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kDarkGreen,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Material(
      color: _kHelpBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // TODO: hubungkan ke WhatsApp pengurus RT (url_launcher: https://wa.me/62xxxxxxxxxx)
        onTap: () => _showInfo('Hubungi Pengurus RT / Admin Bank Sampah.'),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: Colors.white,
                child: Icon(Icons.help_outline_rounded,
                    size: 22, color: Color(0xFFB26A00)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Butuh bantuan langsung?',
                      style: TextStyle(fontSize: 12, color: kTextDark),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hubungi Pengurus RT / Admin Bank Sampah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kDarkGreen,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 20, color: kDarkGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      height: 54,
      child: Material(
        color: _kMint,
        borderRadius: BorderRadius.circular(27),
        child: InkWell(
          borderRadius: BorderRadius.circular(27),
          onTap: _backToLogin,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded, size: 20, color: kDarkGreen),
              SizedBox(width: 10),
              Text(
                'Kembali ke Halaman Masuk',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kDarkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Komponen khusus layar ini
// =====================================================================

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: _kRingOuter,
        ),
        child: Center(
          child: Container(
            width: 122,
            height: 122,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kRingInner,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_kGradStart, _kGradEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.lock_reset_rounded,
                    size: 44, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _kChipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_outlined, size: 14, color: kDarkGreen),
            SizedBox(width: 6),
            Text(
              'Plamo Garden Eco-Waste',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kDarkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}