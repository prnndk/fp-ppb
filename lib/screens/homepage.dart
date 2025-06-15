import 'package:final_project_ppb/screens/auth/login.dart';
import 'package:final_project_ppb/screens/account_screen.dart';
import 'package:final_project_ppb/screens/chat_screen.dart';
import 'package:final_project_ppb/screens/preferences/user_preference_screen.dart';
import 'package:final_project_ppb/screens/history/history_screen.dart';
import 'package:final_project_ppb/screens/reservation_screen.dart';
import 'package:final_project_ppb/models/reservation.dart';
import 'package:final_project_ppb/services/reservation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ReservationService _reservationService = ReservationService();
  late Future<List<Reservation>> _upcomingReservationsFuture;

  @override
  void initState() {
    super.initState();
    _upcomingReservationsFuture = _fetchUpcomingReservations();
  }

  Future<List<Reservation>> _fetchUpcomingReservations() async {
    try {
      final allReservations = await _reservationService.getAllReservations();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final upcomingReservations =
          allReservations.where((reservation) {
            final reservationDay = DateTime(
              reservation.reservationDate.year,
              reservation.reservationDate.month,
              reservation.reservationDate.day,
            );
            return reservationDay.isAtSameMomentAs(today) ||
                reservationDay.isAfter(today);
          }).toList();

      upcomingReservations.sort(
        (a, b) => a.reservationDate.compareTo(b.reservationDate),
      );

      // Limit jadi 2
      return upcomingReservations.take(2).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming reservations: $e');
    }
  }

  String _formatPrice(double price) {
    double rupiahPrice = price * 100;
    return 'Rp ${rupiahPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReservationPage()),
      );
    } else if (index == 3) {
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
    }
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF643F04),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingReservationCard(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B4513).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reservasi #${reservation.id?.substring(0, 8).toUpperCase() ?? "Unknown"}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B4513),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mendatang',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF643F04),
              ),
              const SizedBox(width: 8),
              Text(
                '${reservation.reservationDate.day}/${reservation.reservationDate.month}/${reservation.reservationDate.year}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Color(0xFF643F04)),
              const SizedBox(width: 8),
              Text(
                reservation.reservationTime,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: Color(0xFF643F04)),
              const SizedBox(width: 8),
              Text(
                '${reservation.numberOfGuests} tamu',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
              const Spacer(),
              Text(
                _formatPrice(reservation.totalAmount),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoReservationsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 32,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada reservasi mendatang',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF643F04),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Yuk, buat reservasi pertama kamu dan nikmati pengalaman kuliner yang tak terlupakan!',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReservationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Buat Reservasi Sekarang',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            backgroundColor: const Color(0xFFFEF7E4),
            elevation: 0,
            title: const Text(
              'Beranda',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Color(0xFF643F04),
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Color(0xFF643F04)),
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
          backgroundColor: const Color(0xFFFEF7E4),
          body: RefreshIndicator(
            color: const Color(0xFF8B4513),
            onRefresh: () async {
              setState(() {
                _upcomingReservationsFuture = _fetchUpcomingReservations();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B4513),
                          const Color(0xFF643F04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B4513).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🍽️ Selamat datang!',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Halo, ${user?.displayName?.split(' ').first ?? user?.email?.split('@').first ?? "Foodie"}!',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Siap untuk pengalaman kuliner yang menakjubkan hari ini?',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.restaurant_menu,
                            title: 'Buat Reservasi',
                            subtitle: 'Pesan makanan sekarang',
                            color: const Color(0xFF8B4513),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReservationPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.chat_bubble,
                            title: 'Chat Bot',
                            subtitle: 'Chatbot rekomen menu',
                            color: const Color(0xFF643F04),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Upcoming Reservations Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reservasi Mendatang',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF643F04),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Upcoming Reservations List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FutureBuilder<List<Reservation>>(
                      future: _upcomingReservationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Terjadi kesalahan saat memuat reservasi',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    color: Color(0xFF000000),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ReservationPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B4513),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'Buat Reservasi',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return _buildNoReservationsCard();
                        } else {
                          final upcomingReservations = snapshot.data!;
                          return Column(
                            children:
                                upcomingReservations.take(3).map((reservation) {
                                  return _buildUpcomingReservationCard(
                                    reservation,
                                  );
                                }).toList(),
                          );
                        }
                      },
                    ),
                  ),

                  // Feature Highlights
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'Atur Preferensimu',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserPreferenceScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8B4513,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.dining,
                                    color: Color(0xFF8B4513),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Preferensi Menu',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF643F04),
                                        ),
                                      ),
                                      Text(
                                        'Atur preferensi makanan favorit kamu',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF8B4513),
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom padding for navigation
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF8B4513),
            unselectedItemColor: const Color(0xFFBCAAA4),
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
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
