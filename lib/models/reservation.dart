import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String? id;
  final DateTime reservationDate;
  final String reservationTime;
  final int numberOfGuests;
  final List<OrderItem> orderItems;
  final double totalAmount;
  final DateTime createdAt;

  Reservation({
    this.id,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfGuests,
    required this.orderItems,
    required this.totalAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reservationDate': Timestamp.fromDate(reservationDate),
      'reservationTime': reservationTime,
      'numberOfGuests': numberOfGuests,
      'orderItems': orderItems.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map, String id) {
    return Reservation(
      id: id,
      reservationDate: (map['reservationDate'] as Timestamp).toDate(),
      reservationTime: map['reservationTime']?.toString() ?? '',
      // Fix: Pastikan numberOfGuests selalu int
      numberOfGuests: _parseInt(map['numberOfGuests']) ?? 0,
      orderItems:
          (map['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      // Fix: Pastikan totalAmount selalu double
      totalAmount: _parseDouble(map['totalAmount']) ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class OrderItem {
  final int menuId;
  final String menuName;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderItem({
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'menuName': menuName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      // Fix: Pastikan menuId selalu int
      menuId: _parseInt(map['menuId']) ?? 0,
      menuName: map['menuName']?.toString() ?? '',
      // Fix: Pastikan quantity selalu int
      quantity: _parseInt(map['quantity']) ?? 0,
      // Fix: Pastikan price selalu double
      price: _parseDouble(map['price']) ?? 0.0,
      // Fix: Pastikan totalPrice selalu double
      totalPrice: _parseDouble(map['totalPrice']) ?? 0.0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
