import 'package:flutter/material.dart';
import 'package:final_project_ppb/models/reservation.dart';
import 'package:final_project_ppb/services/reservation_service.dart';
import 'package:final_project_ppb/screens/history/transaction_detail_screen.dart';
import 'package:final_project_ppb/components/custom_button.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ReservationService _reservationService = ReservationService();
  late Future<List<Reservation>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = _fetchReservations();
  }

  Future<List<Reservation>> _fetchReservations() async {
    try {
      return await _reservationService.getAllReservations();
    } catch (e) {
      throw Exception('Failed to fetch reservations: $e');
    }
  }

  String _formatPrice(double price) {
    double rupiahPrice = price * 100;
    return 'Rp ${rupiahPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _deleteReservation(String id) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus reservasi ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      try {
        await _reservationService.deleteReservation(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservasi berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _reservationsFuture = _fetchReservations();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus reservasi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editReservation(Reservation reservation) async {
    final TextEditingController guestsController = TextEditingController(
      text: reservation.numberOfGuests.toString(),
    );
    final TextEditingController dateController = TextEditingController(
      text:
          '${reservation.reservationDate.year}-${reservation.reservationDate.month.toString().padLeft(2, '0')}-${reservation.reservationDate.day.toString().padLeft(2, '0')}',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Reservasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Field
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: reservation.reservationDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Reservasi',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Guest Count Field
              TextField(
                controller: guestsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Tamu',
                  prefixIcon: Icon(Icons.people),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final newGuestsCount =
                      int.tryParse(guestsController.text) ??
                      reservation.numberOfGuests;
                  final dateParts = dateController.text.split('-');
                  final newDate = DateTime(
                    int.parse(dateParts[0]),
                    int.parse(dateParts[1]),
                    int.parse(dateParts[2]),
                  );

                  // Create updated reservation
                  final updatedReservation = Reservation(
                    id: reservation.id,
                    reservationDate: newDate,
                    reservationTime: reservation.reservationTime,
                    numberOfGuests: newGuestsCount,
                    orderItems: reservation.orderItems,
                    totalAmount: reservation.totalAmount,
                    createdAt: reservation.createdAt,
                  );

                  // Update reservasi
                  await _reservationService.updateReservation(
                    updatedReservation,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reservasi berhasil diperbarui!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() {
                      _reservationsFuture = _fetchReservations();
                    });

                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui reservasi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderItemsList(List<OrderItem> orderItems) {
    if (orderItems.isEmpty) {
      return const Text(
        'Tidak ada item pesanan',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Pesanan:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF643F04),
          ),
        ),
        const SizedBox(height: 4),
        ...orderItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• ${item.menuName} x${item.quantity} - Rp${item.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEE),
      body: Column(
        children: [
          // Banner Section
          Container(
            height: 197,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/reservasi.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B4513).withOpacity(0.7),
                    const Color(0xFF8B4513).withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Home',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Title
                      const Text(
                        'Riwayat Reservasi',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Lihat semua reservasi yang pernah kamu lakukan',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content Section with Curved Top Border
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFAEE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: FutureBuilder<List<Reservation>>(
                future: _reservationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B4513),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan:\n${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _reservationsFuture = _fetchReservations();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat reservasi.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final reservations = snapshot.data!;
                    reservations.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    );

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 16),
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailTransactionScreen(
                                        reservation: reservation,
                                      ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Reservasi #${reservation.id?.substring(0, 8).toUpperCase() ?? "Unknown"}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF643F04),
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Tombol Edit
                                        CustomButton(
                                          text: 'Edit',
                                          onPressed:
                                              () =>
                                                  _editReservation(reservation),
                                          backgroundColor: const Color(
                                            0xFF8B4513,
                                          ),
                                          textColor: Colors.white,
                                          width: 90,
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 0,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Tombol Hapus
                                        CustomButton(
                                          text: 'Hapus',
                                          onPressed:
                                              () => _deleteReservation(
                                                reservation.id!,
                                              ),
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          width: 90,
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFF8B4513),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${reservation.reservationDate.day}/${reservation.reservationDate.month}/${reservation.reservationDate.year}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Color(0xFF8B4513),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      reservation.reservationTime,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Color(0xFF8B4513),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${reservation.numberOfGuests} tamu',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatPrice(reservation.totalAmount),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8B4513),
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildOrderItemsList(reservation.orderItems),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
