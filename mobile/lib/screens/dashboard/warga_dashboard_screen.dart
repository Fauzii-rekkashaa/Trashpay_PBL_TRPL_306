import 'package:flutter/material.dart';
import '../auth/auth_shared_widgets.dart';
import 'beranda_tab.dart';
import 'profil_tab.dart';
import '../setoran/setoran_tab.dart';

class WargaDashboardScreen extends StatefulWidget {
  const WargaDashboardScreen({super.key});

  @override
  State<WargaDashboardScreen> createState() => _WargaDashboardScreenState();
}

class _WargaDashboardScreenState extends State<WargaDashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            BerandaTab(onSetorTap: () => setState(() => _index = 1)),
            SetoranTab(onBack: () => setState(() => _index = 0)),
            const _TabPlaceholder(title: 'Transaksi', icon: Icons.account_balance_wallet_outlined),
            const _TabPlaceholder(title: 'Edukasi', icon: Icons.menu_book_outlined),
            ProfilTab(onBack: () => setState(() => _index = 0)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD7F5E6),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: kDarkGreen),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.recycling),
            selectedIcon: Icon(Icons.recycling, color: kDarkGreen),
            label: 'Setor',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: kDarkGreen),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: kDarkGreen),
            label: 'Edukasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: kDarkGreen),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Halaman sementara untuk tab yang belum dibuat.
class _TabPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;
  const _TabPlaceholder({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: kPrimaryGreen),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
          const SizedBox(height: 4),
          const Text('Halaman ini belum dibuat', style: TextStyle(color: kTextGray)),
        ],
      ),
    );
  }
}