class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role; // 'citizen' or 'officer'
  final String language; // 'en' or 'hi'
  final String emergencyPinHash;
  final DateTime createdAt;
  final bool hasConsented;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.language = 'en',
    required this.emergencyPinHash,
    required this.createdAt,
    this.hasConsented = true,
  });

  bool get isOfficer => role == 'officer';

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    String? language,
    String? emergencyPinHash,
    DateTime? createdAt,
    bool? hasConsented,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      language: language ?? this.language,
      emergencyPinHash: emergencyPinHash ?? this.emergencyPinHash,
      createdAt: createdAt ?? this.createdAt,
      hasConsented: hasConsented ?? this.hasConsented,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'language': language,
      'emergencyPinHash': emergencyPinHash,
      'createdAt': createdAt.toIso8601String(),
      'hasConsented': hasConsented,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'citizen',
      language: json['language'] as String? ?? 'en',
      emergencyPinHash: json['emergencyPinHash'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      hasConsented: json['hasConsented'] as bool? ?? true,
    );
  }
}
