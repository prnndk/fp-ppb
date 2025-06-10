import 'package:final_project_ppb/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:final_project_ppb/components/custom_button.dart';
import 'package:final_project_ppb/components/custom_card.dart';
import 'package:final_project_ppb/models/menu.dart';
import 'package:final_project_ppb/models/reservation.dart';
import 'package:final_project_ppb/screens/orderconfirm_screen.dart';
import 'package:final_project_ppb/screens/chat_screen.dart';
import 'package:final_project_ppb/screens/homepage.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final TextEditingController _guestCountController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _timeDisplayText = '';

  //STATIC DATA
  final List<MenuItem> menuItems = [
    MenuItem(
      id: '1',
      name: 'Burger Bangor',
      description:
          'Delicious beef burger with fresh lettuce, tomato, cheese, and our special sauce served with crispy fries',
      imagePath: 'assets/images/burger1.jpg',
      price: 15.99,
    ),
    MenuItem(
      id: '2',
      name: 'Burger GG',
      description:
          'Premium double beef patty burger with bacon, caramelized onions, pickles and garlic mayo',
      imagePath: 'assets/images/burger2.jpg',
      price: 18.99,
    ),
  ];

  Map<String, int> selectedItems = {};

  void _onQuantityChanged(MenuItem item, int quantity) {
    setState(() {
      if (quantity > 0) {
        selectedItems[item.id] = quantity;
      } else {
        selectedItems.remove(item.id);
      }
    });
  }

  // DATE PICKER
  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B4513),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF000000),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF8B4513),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF000000),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
          _timeDisplayText =
              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} - ${pickedTime.format(context)}';
        });
      }
    }
  }

  // CHAT ACTION SHEET
  void _showChatActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Get Menu Recommendation',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Chat with our bot to get personalized menu recommendations',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color(0xFF643F04),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Cancel',
                              onPressed: () => Navigator.pop(context),
                              backgroundColor: Colors.grey[300],
                              textColor: const Color(0xFF643F04),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Start Chat',
                              onPressed: () {
                                Navigator.pop(context);
                                _navigateToChatPage();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  // KONFIRMASI PESANAN HANDLING
  void _proceedToConfirmation() {
    if (_selectedDate == null || _selectedTime == null) {
      _showErrorSnackBar('Pilih waktu reservasi terlebih dahulu');
      return;
    }

    if (_guestCountController.text.isEmpty) {
      _showErrorSnackBar('Pilih jumlah tamu terlebih dahulu');
      return;
    }

    if (selectedItems.isEmpty) {
      _showErrorSnackBar('Pilih menu terlebih dahulu');
      return;
    }

    int numberOfGuests = int.tryParse(_guestCountController.text) ?? 0;
    if (numberOfGuests <= 0) {
      _showErrorSnackBar('Pilih jumlah tamu yang valid');
      return;
    }

    // create order
    List<OrderItem> orderItems = [];
    double totalAmount = 0;

    for (var entry in selectedItems.entries) {
      MenuItem menuItem = menuItems.firstWhere((item) => item.id == entry.key);
      int quantity = entry.value;
      double itemTotal = menuItem.price * quantity;

      orderItems.add(
        OrderItem(
          menuId: menuItem.id,
          menuName: menuItem.name,
          quantity: quantity,
          price: menuItem.price,
          totalPrice: itemTotal,
        ),
      );

      totalAmount += itemTotal;
    }

    // reservation object
    Reservation reservation = Reservation(
      reservationDate: _selectedDate!,
      reservationTime: _selectedTime!.format(context),
      numberOfGuests: numberOfGuests,
      orderItems: orderItems,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
    );

    // KIRIM KE ORDER KONFIRMASI
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderConfirmationPage(
              reservation: reservation,
              menuItems: menuItems,
            ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEE),
      body: Column(
        children: [
          Container(
            height: 197,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/restoran.jpeg'),
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
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                ),
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
                      // Restaurant Title
                      const Text(
                        'Chev Au Restaurant',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Star michelin restaurant',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Section
                    const Text(
                      'Pemesanan',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DateTime Picker
                    GestureDetector(
                      onTap: _selectDateTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Pemesanan *',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF643F04),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF8B4513),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timeDisplayText.isEmpty
                                      ? 'Pilih tanggal dan waktu'
                                      : _timeDisplayText,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    color:
                                        _timeDisplayText.isEmpty
                                            ? Colors.grey[600]
                                            : const Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                            if (_timeDisplayText.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Contoh: 21/08/2025 - 19:00',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Guest Count Field
                    CustomTextField(
                      labelText: "Jumlah Tamu",
                      exampleText: "2",
                      controller: _guestCountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of guests';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Menu Section
                    const Text(
                      'Our Menu',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menu Items
                    ...menuItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MenuCard(
                          menuItem: item,
                          onQuantityChanged: _onQuantityChanged,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Konfirmasi Pemesanan',
                        onPressed: _proceedToConfirmation,
                        height: 56,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Chatbot Section
                    GestureDetector(
                      onTap: _showChatActionSheet,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Not Sure What to Order?',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Chat with our bot to get menu recommendation',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
