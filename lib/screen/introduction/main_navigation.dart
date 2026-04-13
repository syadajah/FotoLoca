import 'package:flutter/material.dart';
import 'package:fotoloca/screen/admin/homepage_admin.dart';
import 'package:fotoloca/screen/global_page/history_transaction.dart';
import 'package:fotoloca/screen/kasir/homepage_kasir.dart';
import 'package:fotoloca/screen/admin/products/product_screen_admin.dart';
import 'package:fotoloca/screen/admin/users/users_screen_admin.dart';
import 'package:fotoloca/screen/global_page/profile_screen.dart';
import 'package:fotoloca/screen/owner/homepage_owner.dart';
import 'package:fotoloca/screen/owner/product_screen_owner.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  final String role;

  const MainNavigation({super.key, required this.role});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late List<Widget> _pages;
  late List<GButton> _navItems;

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  void _setupNavigation() {
    switch (widget.role.toLowerCase()) {
      case 'admin':
        _pages = [
          const Center(child: HomepageAdmin()),
          const Center(child: ProductScreenAdmin()),
          const Center(child: HistoryTransaction()),
          const Center(child: UsersScreenAdmin()),
          const Center(child: ProfileScreen()),
        ];
        _navItems = const [
          GButton(icon: Icons.home, text: 'Beranda'),
          GButton(icon: Icons.camera, text: 'Produk'),
          GButton(icon: Icons.history, text: 'Transaksi'),
          GButton(icon: Icons.group, text: 'Pengguna'),
          GButton(icon: Icons.person, text: 'Profil'),
        ];
        break;

      case 'kasir':
        _pages = [
          const Center(child: HomepageKasir()),
          const Center(child: HistoryTransaction()),
          const Center(child: ProfileScreen()),
        ];
        _navItems = const [
          GButton(icon: Icons.home, text: 'Beranda'),
          GButton(icon: Icons.history, text: 'Transaksi'),
          GButton(icon: Icons.person, text: 'Profil'),
        ];
        break;

      case 'owner':
        _pages = [
          const Center(child: HomepageOwner()),
          const Center(child: ProductScreenOwner()),
          const Center(child: HistoryTransaction()),
          const Center(child: UsersScreenAdmin()),
          const Center(child: ProfileScreen()),
        ];
        _navItems = const [
          GButton(icon: Icons.home, text: 'Beranda'),
          GButton(icon: Icons.camera, text: 'Produk'),
          GButton(icon: Icons.history, text: 'Transaksi'),
          GButton(icon: Icons.group, text: 'Pengguna'),
          GButton(icon: Icons.person, text: 'Profil'),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: GNav(
            tabs: _navItems,
            gap: 3,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: const Color(0xFF7A7A7A),
            color: Colors.grey,

            selectedIndex: _currentIndex,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
