import 'dart:convert';

class Preferensi {
  final String id;
  final String userId;
  final String seafoodPreference;
  final String lactosePreference;
  final String vegetarianPreference;
  final List<String> allergies;
  final String note;

  Preferensi({
    required this.id,
    required this.userId,
    required this.seafoodPreference,
    required this.lactosePreference,
    required this.vegetarianPreference,
    this.allergies = const [],
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'seafoodPreference': seafoodPreference,
      'lactosePreference': lactosePreference,
      'vegetarianPreference': vegetarianPreference,
      'allergies': allergies,
      'note': note,
    };
  }

  factory Preferensi.fromMap(Map<String, dynamic> map, String id) {
    return Preferensi(
      id: id,
      userId: map['userId'] ?? '',
      seafoodPreference: map['seafoodPreference'] ?? '',
      lactosePreference: map['lactosePreference'] ?? '',
      vegetarianPreference: map['vegetarianPreference'] ?? '',
      allergies: List<String>.from(map['allergies'] ?? []),
      note: map['note'] ?? '',
    );
  }
}

class PreferensiRequest {
  final String userId;

  final PreferensiJson preferences;

  PreferensiRequest({required this.userId, required this.preferences});

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'preferences': jsonEncode(preferences.toJson())};
  }

  factory PreferensiRequest.fromJson(Map<String, dynamic> json) {
    return PreferensiRequest(
      userId: json['userId'] ?? '',
      preferences: PreferensiJson.fromJson(json['preferences'] ?? {}),
    );
  }
}

class PreferensiResponse {
  final String message;
  final PreferensiResponseData data;

  PreferensiResponse({required this.message, required this.data});

  factory PreferensiResponse.fromJson(Map<String, dynamic> json) {
    return PreferensiResponse(
      message: json['message'] ?? '',
      data: PreferensiResponseData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data.toJson()};
  }
}

class PreferensiResponseData {
  final int id;
  final String userId;
  final String preferences;
  final String createdAt;
  final String updatedAt;

  PreferensiResponseData({
    required this.id,
    required this.userId,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PreferensiResponseData.fromJson(Map<String, dynamic> json) {
    return PreferensiResponseData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      preferences: json['preferences'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'preferences': preferences,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PreferensiJson {
  final String seafoodPreference;
  final String lactosePreference;
  final String vegetarianPreference;
  final List<String> allergies;
  final String note;

  PreferensiJson({
    required this.seafoodPreference,
    required this.lactosePreference,
    required this.vegetarianPreference,
    this.allergies = const [],
    required this.note,
  });

  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'halalPreference': seafoodPreference,
      'lactosePreference': lactosePreference,
      'vegetarianPreference': vegetarianPreference,
      'allergies': allergies,
      'note': note,
    };
  }

  factory PreferensiJson.fromJson(Map<String, dynamic> json) {
    return PreferensiJson(
      seafoodPreference: json['seafoodPreference'] ?? '',
      lactosePreference: json['lactosePreference'] ?? '',
      vegetarianPreference: json['vegetarianPreference'] ?? '',
      allergies: List<String>.from(json['allergies'] ?? []),
      note: json['note'] ?? '',
    );
  }
}
