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
      reservationTime: map['reservationTime'] ?? '',
      numberOfGuests: map['numberOfGuests'] ?? 0,
      orderItems:
          (map['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

class OrderItem {
  final String menuId;
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
      menuId: map['menuId'] ?? '',
      menuName: map['menuName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}
