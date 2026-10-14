class ReportModel {
  final String id;
  final String category; // 'Broken streetlight', 'Isolated road', 'Harassment', 'Drunk crowd', 'Other'
  final String description;
  final String? photoUrl;
  final double lat;
  final double lng;
  final String locationName;
  final String status; // 'Open', 'In progress', 'Fixed'
  final String? adminNote;
  final DateTime createdAt;
  final bool isAnonymous;
  final int severity; // 1 to 5
  final String timeOfDay; // 'Morning', 'Afternoon', 'Evening', 'Night'
  final String routedAuthority; // 'NAGAR_NIGAM_GHAZIABAD' or 'UP_POLICE'
  final String acknowledgementStatus; // 'Delivered to Control Room', 'Acknowledged by Nagar Nigam', 'Acknowledged by Police', 'Fixed'
  final String wardName;

  const ReportModel({
    required this.id,
    required this.category,
    required this.description,
    this.photoUrl,
    required this.lat,
    required this.lng,
    this.locationName = 'Ghaziabad',
    this.status = 'Open',
    this.adminNote,
    required this.createdAt,
    this.isAnonymous = true,
    this.severity = 3,
    this.timeOfDay = 'Night',
    this.routedAuthority = 'UP_POLICE',
    this.acknowledgementStatus = 'Delivered to Control Room',
    this.wardName = 'Ghaziabad Central',
  });

  String get routedAuthorityLabel {
    if (routedAuthority == 'NAGAR_NIGAM_GHAZIABAD') {
      return 'Nagar Nigam Ghaziabad';
    }
    return 'UP Police (Ghaziabad)';
  }

  /// Automatically resolves authority queue based on hazard category
  static String resolveAuthority(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('streetlight') ||
        cat.contains('road') ||
        cat.contains('civic') ||
        cat.contains('pothole') ||
        cat.contains('infrastructure')) {
      return 'NAGAR_NIGAM_GHAZIABAD';
    }
    return 'UP_POLICE';
  }

  /// Automatically resolves administrative ward based on coordinates or locality
  static String resolveWard(double lat, double lng, String locationName) {
    final loc = locationName.toLowerCase();
    if (loc.contains('indirapuram') ||
        loc.contains('vaishali') ||
        loc.contains('vasundhara') ||
        loc.contains('kaushambi')) {
      return 'Vasundhara Zone (Ward 82)';
    }
    if (loc.contains('sahibabad') ||
        loc.contains('mohan nagar') ||
        loc.contains('rajendra nagar') ||
        loc.contains('arthala')) {
      return 'Mohan Nagar Zone (Ward 64)';
    }
    if (loc.contains('kavi nagar') ||
        loc.contains('raj nagar') ||
        loc.contains('shastri nagar') ||
        loc.contains('govindpuram')) {
      return 'Kavi Nagar Zone (Ward 12)';
    }
    if (loc.contains('vijay nagar') ||
        loc.contains('pratap vihar') ||
        loc.contains('crossings republik')) {
      return 'Vijay Nagar Zone (Ward 28)';
    }
    if (loc.contains('kotwali') ||
        loc.contains('ghantaghar') ||
        loc.contains('model town')) {
      return 'City Kotwali Zone (Ward 41)';
    }
    return 'Ghaziabad Municipal Ward';
  }

  ReportModel copyWith({
    String? id,
    String? category,
    String? description,
    String? photoUrl,
    double? lat,
    double? lng,
    String? locationName,
    String? status,
    String? adminNote,
    DateTime? createdAt,
    bool? isAnonymous,
    int? severity,
    String? timeOfDay,
    String? routedAuthority,
    String? acknowledgementStatus,
    String? wardName,
  }) {
    return ReportModel(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationName: locationName ?? this.locationName,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      severity: severity ?? this.severity,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      routedAuthority: routedAuthority ?? this.routedAuthority,
      acknowledgementStatus:
          acknowledgementStatus ?? this.acknowledgementStatus,
      wardName: wardName ?? this.wardName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'photoUrl': photoUrl,
      'lat': lat,
      'lng': lng,
      'locationName': locationName,
      'status': status,
      'adminNote': adminNote,
      'createdAt': createdAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'severity': severity,
      'timeOfDay': timeOfDay,
      'routedAuthority': routedAuthority,
      'acknowledgementStatus': acknowledgementStatus,
      'wardName': wardName,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as String? ?? 'Other';
    final latVal = (json['lat'] as num?)?.toDouble() ?? 28.6692;
    final lngVal = (json['lng'] as num?)?.toDouble() ?? 77.4538;
    final locName = json['locationName'] as String? ?? 'Ghaziabad';

    return ReportModel(
      id: json['id'] as String,
      category: cat,
      description: json['description'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      lat: latVal,
      lng: lngVal,
      locationName: locName,
      status: json['status'] as String? ?? 'Open',
      adminNote: json['adminNote'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      severity: json['severity'] as int? ?? 3,
      timeOfDay: json['timeOfDay'] as String? ?? 'Night',
      routedAuthority: json['routedAuthority'] as String? ??
          resolveAuthority(cat),
      acknowledgementStatus: json['acknowledgementStatus'] as String? ??
          'Delivered to Control Room',
      wardName: json['wardName'] as String? ??
          resolveWard(latVal, lngVal, locName),
    );
  }
}
