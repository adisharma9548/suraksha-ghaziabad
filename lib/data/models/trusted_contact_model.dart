class TrustedContactModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String relationship;

  const TrustedContactModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.relationship = 'Family',
  });

  TrustedContactModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? relationship,
  }) {
    return TrustedContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  factory TrustedContactModel.fromJson(Map<String, dynamic> json) {
    return TrustedContactModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String? ?? 'Family',
    );
  }
}
