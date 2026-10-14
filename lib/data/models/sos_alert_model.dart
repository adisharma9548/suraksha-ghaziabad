class SosLocationPoint {
  final double lat;
  final double lng;
  final DateTime timestamp;

  const SosLocationPoint({
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

  factory SosLocationPoint.fromJson(Map<String, dynamic> json) {
    return SosLocationPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

class SosAlertModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String status; // 'triggered', 'police_notified', 'assigned', 'resolved', 'cancelled', 'duress_active'
  final DateTime startedAt;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final String? assignedUnitId;
  final String? assignedUnitName;
  final String? assignedOfficerPhone;
  final String? audioUrl;
  final List<SosLocationPoint> locations;
  final String? lastLocationAddress;
  final bool isDuress;

  const SosAlertModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.status,
    required this.startedAt,
    this.assignedAt,
    this.resolvedAt,
    this.assignedUnitId,
    this.assignedUnitName,
    this.assignedOfficerPhone,
    this.audioUrl,
    this.locations = const [],
    this.lastLocationAddress,
    this.isDuress = false,
  });

  SosLocationPoint? get latestLocation =>
      locations.isNotEmpty ? locations.last : null;

  bool get isActive =>
      isDuress || (status != 'resolved' && status != 'cancelled');

  SosAlertModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? status,
    DateTime? startedAt,
    DateTime? assignedAt,
    DateTime? resolvedAt,
    String? assignedUnitId,
    String? assignedUnitName,
    String? assignedOfficerPhone,
    String? audioUrl,
    List<SosLocationPoint>? locations,
    String? lastLocationAddress,
    bool? isDuress,
  }) {
    return SosAlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      assignedUnitId: assignedUnitId ?? this.assignedUnitId,
      assignedUnitName: assignedUnitName ?? this.assignedUnitName,
      assignedOfficerPhone: assignedOfficerPhone ?? this.assignedOfficerPhone,
      audioUrl: audioUrl ?? this.audioUrl,
      locations: locations ?? this.locations,
      lastLocationAddress: lastLocationAddress ?? this.lastLocationAddress,
      isDuress: isDuress ?? this.isDuress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      'assignedAt': assignedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'assignedUnitId': assignedUnitId,
      'assignedUnitName': assignedUnitName,
      'assignedOfficerPhone': assignedOfficerPhone,
      'audioUrl': audioUrl,
      'locations': locations.map((e) => e.toJson()).toList(),
      'lastLocationAddress': lastLocationAddress,
      'isDuress': isDuress,
    };
  }

  factory SosAlertModel.fromJson(Map<String, dynamic> json) {
    return SosAlertModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Citizen',
      userPhone: json['userPhone'] as String? ?? '',
      status: json['status'] as String? ?? 'triggered',
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      assignedUnitId: json['assignedUnitId'] as String?,
      assignedUnitName: json['assignedUnitName'] as String?,
      assignedOfficerPhone: json['assignedOfficerPhone'] as String?,
      audioUrl: json['audioUrl'] as String?,
      locations: json['locations'] != null
          ? (json['locations'] as List)
              .map((e) => SosLocationPoint.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      lastLocationAddress: json['lastLocationAddress'] as String?,
      isDuress: json['isDuress'] as bool? ?? false,
    );
  }
}
