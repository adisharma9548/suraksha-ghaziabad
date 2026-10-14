import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/report_model.dart';
import '../../../core/theme/app_colors.dart';

class HeatmapCanvasLayer extends StatelessWidget {
  final List<ReportModel> reports;

  const HeatmapCanvasLayer({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    return CustomPaint(
      painter: _HeatmapPainter(camera: camera, reports: reports),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final MapCamera camera;
  final List<ReportModel> reports;

  _HeatmapPainter({required this.camera, required this.reports});

  @override
  void paint(Canvas canvas, Size size) {
    for (final report in reports) {
      final point = LatLng(report.lat, report.lng);
      final offset = camera.getOffsetFromOrigin(point);

      // Scale radius by zoom level and report severity
      final zoom = camera.zoom;
      final radius = (25.0 * (zoom / 13.0)).clamp(18.0, 50.0);

      Color coreColor;
      Color haloColor;

      if (report.severity >= 4 || report.category == 'Harassment') {
        coreColor = AppColors.sosRed.withOpacity(0.55);
        haloColor = AppColors.sosRed.withOpacity(0.0);
      } else if (report.severity == 3 || report.category == 'Isolated road') {
        coreColor = AppColors.warningAmber.withOpacity(0.45);
        haloColor = AppColors.warningAmber.withOpacity(0.0);
      } else {
        coreColor = AppColors.safeGreen.withOpacity(0.35);
        haloColor = AppColors.safeGreen.withOpacity(0.0);
      }

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [coreColor, haloColor],
          stops: const [0.2, 1.0],
        ).createShader(
          Rect.fromCircle(center: offset, radius: radius),
        );

      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.camera != camera || oldDelegate.reports != reports;
  }
}
