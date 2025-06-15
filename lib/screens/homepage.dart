import 'package:final_project_ppb/screens/auth/login.dart';
import 'package:final_project_ppb/screens/account_screen.dart';
import 'package:final_project_ppb/screens/preferences/user_preference_screen.dart';
import 'package:final_project_ppb/screens/history/history_screen.dart';
import 'package:final_project_ppb/screens/reservation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 4) {
      // Navigasi ke halaman akun
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountScreen()),
      );
    } else if (index == 1) {
      // Navigasi ke halaman reservasi
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReservationPage()),
      );
    } else if (index == 3) {
      // Navigasi ke halaman history
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserPreferenceScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
      // Tambahkan navigasi ke halaman lain jika sudah ada
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        final user = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8F5F2),
            elevation: 0,
            title: const Text(
              'Beranda',
              style: TextStyle(color: Color(0xFF4A2C2A)),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Color(0xFF4A2C2A)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF8F5F2),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sapaan Personal
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Selamat datang kembali, ${user?.displayName ?? user?.email ?? "Pengguna"}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Color(0xFFE0D6CF)),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.search, color: Color(0xFFBCAAA4)),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Cari restoran atau menu favoritmu...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Filter/Category Cepat
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Tambahkan Chip kategori di sini
                    ],
                  ),
                ),
                // Rekomendasi untuk Anda
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: const Text(
                    'Rekomendasi untuk Anda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Tambahkan Card rekomendasi di sini
                      ],
                    ),
                  ),
                ),
                // Restoran Populer
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: const Text(
                    'Tambah Prefensi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Tambahkan Card restoran populer di sini
                      ],
                    ),
                  ),
                ),
                // Reservasi Mendatang
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: const Text(
                    'Reservasi Mendatang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Tambahkan Card reservasi mendatang di sini
                    ],
                  ),
                ),
                // Padding bawah agar konten tidak tertutup bottom nav
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF4A2C2A),
            unselectedItemColor: const Color(0xFFBCAAA4),
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Reservasi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: 'Preferensi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
            ],
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
