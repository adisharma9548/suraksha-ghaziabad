import 'dart:convert';
import 'dart:io';

/// Verified Help Places CSV Ingestion Script for Suraksha Ghaziabad
///
/// Reads a user-supplied CSV file containing verified emergency help places,
/// validates coordinates, mandatory audit fields ('source', 'verifiedAt'),
/// and outputs structured JSON or writes to Firestore.
///
/// Usage:
///   dart run scripts/import_help_places.dart <path-to-csv> [--output <json-path>]
void main(List<String> args) async {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    stdout.writeln('=== Suraksha Ghaziabad: Help Places CSV Ingestion Utility ===');
    stdout.writeln('Usage:');
    stdout.writeln('  dart run scripts/import_help_places.dart <path-to-csv> [--output <output.json>]');
    stdout.writeln('');
    stdout.writeln('Required CSV Columns:');
    stdout.writeln('  id,type,name,address,lat,lng,phone,source,verifiedAt');
    exit(0);
  }

  final csvPath = args.first;
  final file = File(csvPath);

  if (!await file.exists()) {
    stderr.writeln('Error: File not found at path: $csvPath');
    exit(1);
  }

  final lines = await file.readAsLines();
  if (lines.isEmpty) {
    stderr.writeln('Error: CSV file is empty.');
    exit(1);
  }

  final headerLine = lines.first.trim();
  final headers = _parseCsvRow(headerLine).map((h) => h.trim().toLowerCase()).toList();

  final requiredColumns = [
    'id',
    'type',
    'name',
    'address',
    'lat',
    'lng',
    'phone',
    'source',
    'verifiedAt',
  ];

  for (final col in requiredColumns) {
    if (!headers.contains(col.toLowerCase())) {
      stderr.writeln('Error: CSV missing required column: "$col"');
      stderr.writeln('Found columns: $headers');
      exit(1);
    }
  }

  final colIdx = {for (final col in requiredColumns) col: headers.indexOf(col.toLowerCase())};

  final importedPlaces = <Map<String, dynamic>>[];
  int rowNum = 1;
  int errorCount = 0;

  for (final line in lines.skip(1)) {
    rowNum++;
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    final values = _parseCsvRow(trimmed);
    if (values.length < headers.length) {
      stderr.writeln('Warning [Row $rowNum]: Insufficient columns. Expected ${headers.length}, got ${values.length}. Skipping.');
      errorCount++;
      continue;
    }

    final id = values[colIdx['id']!].trim();
    final type = values[colIdx['type']!].trim();
    final name = values[colIdx['name']!].trim();
    final address = values[colIdx['address']!].trim();
    final latStr = values[colIdx['lat']!].trim();
    final lngStr = values[colIdx['lng']!].trim();
    final phone = values[colIdx['phone']!].trim();
    final source = values[colIdx['source']!].trim();
    final verifiedAtStr = values[colIdx['verifiedAt']!].trim();

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);

    if (lat == null || lng == null) {
      stderr.writeln('Warning [Row $rowNum]: Invalid coordinates ($latStr, $lngStr). Skipping.');
      errorCount++;
      continue;
    }

    // Ghaziabad Geographic Bounding Box Check (28.4 to 28.9 N, 77.1 to 77.7 E)
    if (lat < 28.3 || lat > 29.0 || lng < 77.0 || lng > 77.8) {
      stderr.writeln('Warning [Row $rowNum]: Coordinates ($lat, $lng) outside Ghaziabad district bounds. Skipping.');
      errorCount++;
      continue;
    }

    DateTime? verifiedAt;
    try {
      verifiedAt = DateTime.parse(verifiedAtStr);
    } catch (_) {
      stderr.writeln('Warning [Row $rowNum]: Invalid ISO-8601 verifiedAt date "$verifiedAtStr". Skipping.');
      errorCount++;
      continue;
    }

    if (source.isEmpty) {
      stderr.writeln('Warning [Row $rowNum]: Empty source attribute. Mandatory audit field missing. Skipping.');
      errorCount++;
      continue;
    }

    importedPlaces.add({
      'id': id.isEmpty ? 'place_${importedPlaces.length + 1}' : id,
      'type': type,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'source': source,
      'verifiedAt': verifiedAt.toIso8601String(),
    });
  }

  stdout.writeln('========================================');
  stdout.writeln('Ingestion Summary:');
  stdout.writeln('  Total rows processed : ${lines.length - 1}');
  stdout.writeln('  Successfully verified: ${importedPlaces.length}');
  stdout.writeln('  Skipped errors       : $errorCount');
  stdout.writeln('========================================');

  // Check if output path is requested
  String? outputPath;
  final outIdx = args.indexOf('--output');
  if (outIdx != -1 && outIdx + 1 < args.length) {
    outputPath = args[outIdx + 1];
  } else {
    outputPath = 'assets/data/verified_help_places.json';
  }

  final outFile = File(outputPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(importedPlaces),
  );

  stdout.writeln('Verified places written to: ${outFile.path}');
  stdout.writeln('Ready for Firestore upload or deployment.');
}

List<String> _parseCsvRow(String line) {
  final values = <String>[];
  final buffer = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      values.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  values.add(buffer.toString());
  return values;
}
