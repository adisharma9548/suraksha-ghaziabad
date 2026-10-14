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
  });

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
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      photoUrl: json['photoUrl'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      locationName: json['locationName'] as String? ?? 'Ghaziabad',
      status: json['status'] as String? ?? 'Open',
      adminNote: json['adminNote'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      severity: json['severity'] as int? ?? 3,
      timeOfDay: json['timeOfDay'] as String? ?? 'Night',
    );
  }
}
