import 'package:flutter/material.dart';
import 'package:final_project_ppb/components/custom_button.dart';
import 'package:final_project_ppb/models/menu.dart';
import 'package:final_project_ppb/models/reservation.dart';
import 'package:final_project_ppb/services/reservation_service.dart';
import 'package:final_project_ppb/screens/homepage.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Reservation reservation;
  final List<MenuItem> menuItems;

  const OrderConfirmationPage({
    Key? key,
    required this.reservation,
    required this.menuItems,
  }) : super(key: key);

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final ReservationService _reservationService = ReservationService();
  bool _isLoading = false;
  late Reservation _currentReservation;

  @override
  void initState() {
    super.initState();
    _currentReservation = Reservation(
      reservationDate: widget.reservation.reservationDate,
      reservationTime: widget.reservation.reservationTime,
      numberOfGuests: widget.reservation.numberOfGuests,
      orderItems: List<OrderItem>.from(widget.reservation.orderItems),
      totalAmount: widget.reservation.totalAmount,
      createdAt: widget.reservation.createdAt,
    );
  }

  void _addAnotherOrder() {
    Navigator.pop(context);
  }

  void _updateQuantity(OrderItem orderItem, int newQuantity) {
    setState(() {
      final index = _currentReservation.orderItems.indexWhere(
        (item) => item.menuId == orderItem.menuId,
      );

      if (index != -1) {
        if (newQuantity <= 0) {
          _currentReservation.orderItems.removeAt(index);
        } else {
          _currentReservation.orderItems[index] = OrderItem(
            menuId: orderItem.menuId,
            menuName: orderItem.menuName,
            quantity: newQuantity,
            price: orderItem.price,
            totalPrice: orderItem.price * newQuantity,
          );
        }
        _recalculateTotal();
      }
    });
  }

  void _removeItem(OrderItem orderItem) {
    setState(() {
      _currentReservation.orderItems.removeWhere(
        (item) => item.menuId == orderItem.menuId,
      );
      _recalculateTotal();
    });
  }

  void _recalculateTotal() {
    double newTotal = 0;
    for (var item in _currentReservation.orderItems) {
      newTotal += item.totalPrice;
    }
    _currentReservation = Reservation(
      reservationDate: _currentReservation.reservationDate,
      reservationTime: _currentReservation.reservationTime,
      numberOfGuests: _currentReservation.numberOfGuests,
      orderItems: _currentReservation.orderItems,
      totalAmount: newTotal,
      createdAt: _currentReservation.createdAt,
    );
  }

  // rupiah
  String _formatPrice(double price) {
    double rupiahPrice = price * 100;
    return 'Rp ${rupiahPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _confirmReservation() async {
    if (_currentReservation.orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu menu untuk reservasi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String reservationId = await _reservationService.createReservation(
        _currentReservation,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text(
                  'Reservasi berhasil!',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF643F04),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF8B4513),
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your reservation has been confirmed!\nReservation ID: ${reservationId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Color(0xFF643F04),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  CustomButton(
                    text: 'OK',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm reservation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = _currentReservation.totalAmount;

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
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Back',
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
                    const Text(
                      'Order Confirmation',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // reservation detail
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reservation Details',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF643F04),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF8B4513),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_currentReservation.reservationDate.day}/${_currentReservation.reservationDate.month}/${_currentReservation.reservationDate.year}',
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
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF8B4513),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _currentReservation.reservationTime,
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
                              const Icon(
                                Icons.people,
                                color: Color(0xFF8B4513),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_currentReservation.numberOfGuests} guests',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // if no items
                    if (_currentReservation.orderItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No items in your order',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Order items list
                      ..._currentReservation.orderItems.map((orderItem) {
                        MenuItem? menuItem;
                        try {
                          menuItem = widget.menuItems.firstWhere(
                            (item) => item.id == orderItem.menuId,
                          );
                        } catch (e) {
                          // Menu item not found, use placeholder
                          const Text(
                            'Makanan nyam',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Menu image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[300],
                                ),
                                child:
                                    menuItem != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            menuItem.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const Icon(
                                                Icons.fastfood,
                                                color: Color(0xFF8B4513),
                                              );
                                            },
                                          ),
                                        )
                                        : const Icon(
                                          Icons.fastfood,
                                          color: Color(0xFF8B4513),
                                        ),
                              ),
                              const SizedBox(width: 16),

                              // Menu details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      orderItem.menuName,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (menuItem != null)
                                      Text(
                                        menuItem.category,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatPrice(orderItem.price)} x ${orderItem.quantity}',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        color: Color(0xFF643F04),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total: ${_formatPrice(orderItem.totalPrice)}',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8B4513),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity controls and delete
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () => _updateQuantity(
                                              orderItem,
                                              orderItem.quantity - 1,
                                            ),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B4513),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 32,
                                        alignment: Alignment.center,
                                        child: Text(
                                          orderItem.quantity.toString(),
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF000000),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:
                                            () => _updateQuantity(
                                              orderItem,
                                              orderItem.quantity + 1,
                                            ),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B4513),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _removeItem(orderItem),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Color(0xFF8B4513),
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 16),

                    // Add another order button
                    GestureDetector(
                      onTap: _addAnotherOrder,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B4513),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF8B4513),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Another Order',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Total amount card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _formatPrice(totalAmount),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Confirm reservation button
                    CustomButton(
                      text:
                          _isLoading ? 'Processing...' : 'Confirm Reservation',
                      onPressed: _confirmReservation,
                      backgroundColor: const Color(0xFF8B4513),
                      textColor: Colors.white,
                      width: double.infinity,
                      height: 56,
                    ),
                    const SizedBox(height: 16),

                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B4513),
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
