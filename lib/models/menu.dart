class MenuItem {
  final int id;
  final String name;
  final String? description;
  final String imageUrl;
  final double price;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      price: (json['price'] / 100).toDouble(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': (price * 100).round(),
      'category': category,
    };
  }
}

// Non paginated
// class MenuResponse {
//   final String message;
//   final List<MenuItem> data;

//   MenuResponse({
//     required this.message,
//     required this.data,
//   });

//   factory MenuResponse.fromJson(Map<String, dynamic> json) {
//     return MenuResponse(
//       message: json['message'],
//       data: (json['data'] as List)
//           .map((item) => MenuItem.fromJson(item))
//           .toList(),
//     );
//   }
// }

// For paginated responses (second API) - simplified
class MenuResponse {
  final String message;
  final MenuData data;

  MenuResponse({required this.message, required this.data});

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      message: json['message'],
      data: MenuData.fromJson(json['data']),
    );
  }
}

class MenuData {
  final int currentPage;
  final List<MenuItem> data;
  final int lastPage;
  final String? nextPageUrl;
  final int perPage;
  final String? prevPageUrl;
  final int total;

  MenuData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    this.nextPageUrl,
    required this.perPage,
    this.prevPageUrl,
    required this.total,
  });

  factory MenuData.fromJson(Map<String, dynamic> json) {
    return MenuData(
      currentPage: json['current_page'],
      data:
          (json['data'] as List)
              .map((item) => MenuItem.fromJson(item))
              .toList(),
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      total: json['total'],
    );
  }
}
