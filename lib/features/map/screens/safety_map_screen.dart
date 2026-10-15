import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';
import '../widgets/heatmap_canvas_layer.dart';
import '../widgets/report_spot_details_modal.dart';

/// Native iOS Safety Map Screen
/// Fully compliant with Apple HIG and color-blind accessibility (geometric shapes + high contrast markers).
class SafetyMapScreen extends ConsumerStatefulWidget {
  const SafetyMapScreen({super.key});

  @override
  ConsumerState<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends ConsumerState<SafetyMapScreen> {
  final MapController _mapController = MapController();
  String _selectedCategory = 'All';
  bool _showHeatmap = true;

  final List<String> _categories = [
    'All',
    'Broken streetlight',
    'Isolated road',
    'Harassment',
    'Drunk crowd',
    'Other',
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Broken streetlight':
        return CupertinoIcons.lightbulb_fill;
      case 'Isolated road':
        return CupertinoIcons.arrow_branch;
      case 'Harassment':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'Drunk crowd':
        return CupertinoIcons.person_3_fill;
      default:
        return CupertinoIcons.question_circle_fill;
    }
  }

  void _showSpotDetails(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportSpotDetailsModal(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    final reportsAsync = ref.watch(allReportsStreamProvider);
    final allReports = reportsAsync.value ?? [];
    final filteredReports = allReports.where((r) {
      return _selectedCategory == 'All' || r.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Flutter OpenStreetMap layer
          reportsAsync.when(
            data: (_) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(
                    AppConstants.ghaziabadCenterLat,
                    AppConstants.ghaziabadCenterLng,
                  ),
                  initialZoom: AppConstants.defaultMapZoom,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.suraksha.ghaziabad',
                  ),
                  if (_showHeatmap) HeatmapCanvasLayer(reports: filteredReports),
                  MarkerLayer(
                    markers: [
                      // User Current Location Pin (Apple Maps Style Pulsing Dot)
                      Marker(
                        point: const LatLng(
                          AppConstants.ghaziabadCenterLat,
                          AppConstants.ghaziabadCenterLng,
                        ),
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentBlue.withOpacity(0.25),
                            ),
                            child: Center(
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentBlue,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Multi-Cue Color-Blind Safe Incident Markers
                      ...filteredReports.map((report) {
                        final icon = _getCategoryIcon(report.category);
                        final isHarassment = report.category == 'Harassment';

                        return Marker(
                          point: LatLng(report.lat, report.lng),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => _showSpotDetails(report),
                            child: Center(
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  // Squircle shape for Harassment, circle for general incidents
                                  borderRadius: isHarassment
                                      ? BorderRadius.circular(10)
                                      : BorderRadius.circular(19),
                                  color: isHarassment
                                      ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
                                      : (isDark ? const Color(0xFF38383A) : const Color(0xFF48484A)),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isHarassment ? 2.5 : 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icon,
                                  color: isHarassment
                                      ? (isDark ? Colors.black : Colors.white)
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
            loading: () => Center(
              child: CupertinoActivityIndicator(
                radius: 16,
                color: primaryTextColor,
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                'Map loading error: $err',
                style: IosTypography.subhead(color: secondaryTextColor),
              ),
            ),
          ),

          // Native iOS Frosted Top Navigation & Control Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Translucent Frosted Glass Header Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: separatorColor.withOpacity(0.6)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.map_pin_ellipse,
                              color: primaryTextColor,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Ghaziabad Safety Map',
                                    style: IosTypography.headline(color: primaryTextColor),
                                  ),
                                  Text(
                                    '${filteredReports.length} flagged locations',
                                    style: IosTypography.caption1(color: secondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                            // iOS Native Heatmap Toggle Pill
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 34,
                              onPressed: () {
                                setState(() => _showHeatmap = !_showHeatmap);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _showHeatmap
                                      ? primaryTextColor
                                      : (isDark ? AppColors.surfaceDark : AppColors.secondaryBackgroundLight),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: separatorColor),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showHeatmap
                                          ? CupertinoIcons.layers_alt_fill
                                          : CupertinoIcons.layers_alt,
                                      size: 14,
                                      color: _showHeatmap
                                          ? (isDark ? Colors.black : Colors.white)
                                          : secondaryTextColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showHeatmap ? 'Heatmap' : 'Pins',
                                      style: IosTypography.caption1(
                                        color: _showHeatmap
                                            ? (isDark ? Colors.black : Colors.white)
                                            : primaryTextColor,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Horizontal Category Filter Pills (Apple HIG standard)
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 36,
                            onPressed: () {
                              setState(() => _selectedCategory = cat);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryTextColor
                                    : (isDark ? AppColors.surfaceDark.withOpacity(0.9) : Colors.white.withOpacity(0.95)),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? primaryTextColor : separatorColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    Icon(
                                      CupertinoIcons.checkmark,
                                      size: 12,
                                      color: isDark ? Colors.black : Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    cat,
                                    style: IosTypography.footnote(
                                      color: isSelected
                                          ? (isDark ? Colors.black : Colors.white)
                                          : primaryTextColor,
                                      weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (filteredReports.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: separatorColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.info_circle,
                                  size: 16,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No reports found in this category.',
                                  style: IosTypography.footnote(color: secondaryTextColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Floating Recenter Map Button (Native iOS 44x44pt Squircle)
          Positioned(
            right: 16,
            bottom: 24,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 46,
              onPressed: () {
                _mapController.move(
                  const LatLng(
                    AppConstants.ghaziabadCenterLat,
                    AppConstants.ghaziabadCenterLng,
                  ),
                  AppConstants.defaultMapZoom,
                );
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: separatorColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.location_fill,
                  color: primaryTextColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
