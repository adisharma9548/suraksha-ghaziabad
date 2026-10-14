class TripPoint {
  final double lat;
  final double lng;
  final DateTime timestamp;

  const TripPoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TripPoint.fromJson(Map<String, dynamic> json) {
    return TripPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

class TripModel {
  final String id;
  final String userId;
  final String userName;
  final String destination;
  final double startLat;
  final double startLng;
  final double destLat;
  final double destLng;
  final List<TripPoint> routePoints;
  final String status; // 'active', 'completed', 'alerted', 'stopped_warning'
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastCheckInAt;
  final List<String> trustedContactPhones;

  const TripModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.destination,
    required this.startLat,
    required this.startLng,
    required this.destLat,
    required this.destLng,
    this.routePoints = const [],
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.lastCheckInAt,
    this.trustedContactPhones = const [],
  });

  bool get isActive => status == 'active' || status == 'stopped_warning';

  TripModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? destination,
    double? startLat,
    double? startLng,
    double? destLat,
    double? destLng,
    List<TripPoint>? routePoints,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastCheckInAt,
    List<String>? trustedContactPhones,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      destination: destination ?? this.destination,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      routePoints: routePoints ?? this.routePoints,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastCheckInAt: lastCheckInAt ?? this.lastCheckInAt,
      trustedContactPhones: trustedContactPhones ?? this.trustedContactPhones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'destination': destination,
      'startLat': startLat,
      'startLng': startLng,
      'destLat': destLat,
      'destLng': destLng,
      'routePoints': routePoints.map((e) => e.toJson()).toList(),
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastCheckInAt': lastCheckInAt.toIso8601String(),
      'trustedContactPhones': trustedContactPhones,
    };
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Citizen',
      destination: json['destination'] as String? ?? '',
      startLat: (json['startLat'] as num).toDouble(),
      startLng: (json['startLng'] as num).toDouble(),
      destLat: (json['destLat'] as num).toDouble(),
      destLng: (json['destLng'] as num).toDouble(),
      routePoints: json['routePoints'] != null
          ? (json['routePoints'] as List)
              .map((e) => TripPoint.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      status: json['status'] as String? ?? 'active',
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastCheckInAt: json['lastCheckInAt'] != null
          ? DateTime.parse(json['lastCheckInAt'] as String)
          : DateTime.now(),
      trustedContactPhones: (json['trustedContactPhones'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
