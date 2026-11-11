import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/auth_shared_widgets.dart'; 
import '../auth/login_screen.dart';

const Color _kBgTop = Color(0xFFE6F8E9);
const Color _kBgMid = Color(0xFFF3F8FE);
const Color _kBgBottom = Color(0xFFFFFFFF);
const Color _kPill = Color(0xFFB8F2C0);
const Color _kInfoBg = Color(0xFFE3F1FC);
const Color _kMint = Color(0xFF9BF0A8);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    const Widget next = LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kBgTop, _kBgMid, _kBgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                          child: Column(
                            children: [
                              const _TopBadge(),
                              const Spacer(flex: 2),
                              const _LogoBlock(),
                              const SizedBox(height: 22),
                              const _TaglinePill(),
                              const Spacer(flex: 2),
                              const _EnvironmentCard(),
                              const Spacer(flex: 2),
                              const _LoadingPill(),
                              const SizedBox(height: 14),
                              const _VersionFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Komponen khusus layar ini
// =====================================================================

class _TopBadge extends StatelessWidget {
  const _TopBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 18, color: kDarkGreen),
          SizedBox(width: 10),
          Text(
            'BANK SAMPAH DIGITAL WARGA',
            style: TextStyle(
              fontSize: 14.5,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: kDarkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 156,
          height: 156,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kDarkGreen.withValues(alpha: 0.14),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            // Kalau file logo belum ada, tampil ikon cadangan.
            errorBuilder: (_, __, ___) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.recycling_rounded, size: 70, color: kDarkGreen),
                SizedBox(height: 2),
                Text(
                  'TrashPay',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kDarkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'TrashPay',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: kDarkGreen,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'PLAMO GARDEN',
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w800,
            color: kDarkGreen,
          ),
        ),
        const Text(
          'ECO-WASTE',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
            color: kDarkGreen,
          ),
        ),
      ],
    );
  }
}

class _TaglinePill extends StatelessWidget {
  const _TaglinePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _kPill,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, size: 18, color: kDarkGreen),
          SizedBox(width: 8),
          Text(
            'Dari Sampah Menjadi Rupiah',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: kDarkGreen,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.auto_awesome_rounded, size: 16, color: kDarkGreen),
        ],
      ),
    );
  }
}

class _EnvironmentCard extends StatelessWidget {
  const _EnvironmentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/plamo_garden.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Stack(
                      fit: StackFit.expand,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF8FD3A0), Color(0xFF2E7D32)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 40,
                          top: 30,
                          child: Icon(Icons.cottage_rounded,
                              size: 58, color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        Positioned(
                          right: 14,
                          top: 20,
                          child: Icon(Icons.home_work_rounded,
                              size: 64, color: Colors.white.withValues(alpha: 0.35)),
                        ),
                      ],
                    ),
                  ),
                  // Gradasi gelap di bawah supaya teks terbaca.
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xB3103D1A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Row(
                      children: [
                        Icon(Icons.recycling_rounded, size: 16, color: _kMint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lingkungan Asri & Bersih',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'RT 04 / RW 08',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kMint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kInfoBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.apartment_rounded, size: 18, color: kDarkGreen),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 13, height: 1.4, color: kTextDark),
                      children: [
                        TextSpan(text: 'Sistem Pengelolaan Bank Sampah Warga '),
                        TextSpan(
                          text: 'RT 04 / RW 08',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' Perumahan Plamo Garden Batam'),
                      ],
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
}

class _LoadingPill extends StatelessWidget {
  const _LoadingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: kDarkGreen),
          ),
          SizedBox(width: 12),
          Text(
            'Menghubungkan sistem warga...',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: kDarkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Versi 2.4.0 (PBL Part-2) • Mitra Lingkungan Hidup',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: kTextGray.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'BATAM ECO-INITIATIVE • MANDIRI & LESTARI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            color: kTextGray.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}