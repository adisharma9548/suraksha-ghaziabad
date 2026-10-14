class PatrolUnitModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final bool available;
  final String officerName;
  final String phone;

  const PatrolUnitModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.available,
    required this.officerName,
    required this.phone,
  });

  PatrolUnitModel copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    bool? available,
    String? officerName,
    String? phone,
  }) {
    return PatrolUnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      available: available ?? this.available,
      officerName: officerName ?? this.officerName,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'available': available,
      'officerName': officerName,
      'phone': phone,
    };
  }

  factory PatrolUnitModel.fromJson(Map<String, dynamic> json) {
    return PatrolUnitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      available: json['available'] as bool? ?? true,
      officerName: json['officerName'] as String? ?? 'Patrol Officer',
      phone: json['phone'] as String? ?? '112',
    );
  }
}
