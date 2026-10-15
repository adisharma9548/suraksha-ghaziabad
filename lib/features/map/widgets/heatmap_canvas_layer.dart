import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/report_model.dart';

/// Apple HIG Greyscale Density Heatmap Canvas Layer
/// Uses luminance density and radius scaling instead of chromatic hue,
/// ensuring 100% readability across Protanopia, Deuteranopia, Tritanopia, and Monochromacy.
class HeatmapCanvasLayer extends StatelessWidget {
  final List<ReportModel> reports;

  const HeatmapCanvasLayer({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      painter: _HeatmapPainter(camera: camera, reports: reports, isDark: isDark),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final MapCamera camera;
  final List<ReportModel> reports;
  final bool isDark;

  _HeatmapPainter({
    required this.camera,
    required this.reports,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDark ? Colors.white : Colors.black;

    for (final report in reports) {
      final point = LatLng(report.lat, report.lng);
      final offset = camera.getOffsetFromOrigin(point);

      // Scale radius by zoom level and report severity
      final zoom = camera.zoom;
      final radius = (25.0 * (zoom / 13.0)).clamp(18.0, 52.0);

      // Luminance density tiers:
      // High severity (4-5 or Harassment): dense high-contrast core
      // Moderate severity (3): medium density
      // Low severity (1-2): subtle light density
      double coreOpacity;
      if (report.severity >= 4 || report.category == 'Harassment') {
        coreOpacity = isDark ? 0.65 : 0.50;
      } else if (report.severity == 3 || report.category == 'Isolated road') {
        coreOpacity = isDark ? 0.40 : 0.30;
      } else {
        coreOpacity = isDark ? 0.20 : 0.15;
      }

      final coreColor = baseColor.withOpacity(coreOpacity);
      final haloColor = baseColor.withOpacity(0.0);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [coreColor, haloColor],
          stops: const [0.25, 1.0],
        ).createShader(
          Rect.fromCircle(center: offset, radius: radius),
        );

      canvas.drawCircle(offset, radius, paint);

      // If high risk, draw an inner tactile high-contrast ring for shape differentiation
      if (report.severity >= 4 || report.category == 'Harassment') {
        final ringPaint = Paint()
          ..color = baseColor.withOpacity(isDark ? 0.4 : 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(offset, radius * 0.4, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.camera != camera ||
        oldDelegate.reports != reports ||
        oldDelegate.isDark != isDark;
  }
}
