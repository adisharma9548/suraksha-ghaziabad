class HelpPlaceModel {
  final String id;
  final String type; // 'Police Station', 'Women\'s Help Desk', 'Hospital'
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String phone;
  final String source;
  final DateTime? verifiedAt;

  const HelpPlaceModel({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.phone,
    this.source = 'Official UP Directory',
    this.verifiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'source': source,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  factory HelpPlaceModel.fromJson(Map<String, dynamic> json) {
    return HelpPlaceModel(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? 'Ghaziabad, UP',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      phone: json['phone'] as String? ?? '112',
      source: json['source'] as String? ?? 'Official Directory',
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'] as String)
          : null,
    );
  }
}
