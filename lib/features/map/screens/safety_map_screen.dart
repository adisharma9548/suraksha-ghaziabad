import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';
import '../widgets/heatmap_canvas_layer.dart';
import '../widgets/report_spot_details_modal.dart';

class SafetyMapScreen extends ConsumerStatefulWidget {
  const SafetyMapScreen({super.key});

  @override
  ConsumerState<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends ConsumerState<SafetyMapScreen> {
  final MapController _mapController = MapController();
  String _selectedCategory = 'All';
  final String _selectedStatus = 'All';
  bool _showHeatmap = true;

  final List<String> _categories = [
    'All',
    'Broken streetlight',
    'Isolated road',
    'Harassment',
    'Drunk crowd',
    'Other',
  ];

  Color _getMarkerColor(String category) {
    switch (category) {
      case 'Harassment':
        return AppColors.sosRed;
      case 'Isolated road':
        return AppColors.warningAmberDark;
      case 'Drunk crowd':
        return Colors.deepOrange;
      case 'Broken streetlight':
        return AppColors.primaryPurple;
      default:
        return AppColors.infoBlue;
    }
  }

  IconData _getMarkerIcon(String category) {
    switch (category) {
      case 'Broken streetlight':
        return Icons.lightbulb_outline_rounded;
      case 'Isolated road':
        return Icons.alt_route_rounded;
      case 'Harassment':
        return Icons.warning_rounded;
      case 'Drunk crowd':
        return Icons.group_off_rounded;
      default:
        return Icons.report_problem_rounded;
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
    final reportsAsync = ref.watch(allReportsStreamProvider);

    return Scaffold(
      body: Stack(
        children: [
          reportsAsync.when(
            data: (allReports) {
              final filteredReports = allReports.where((r) {
                final matchCat =
                    _selectedCategory == 'All' || r.category == _selectedCategory;
                final matchStatus =
                    _selectedStatus == 'All' || r.status == _selectedStatus;
                return matchCat && matchStatus;
              }).toList();

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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.suraksha.ghaziabad',
                  ),
                  if (_showHeatmap)
                    HeatmapCanvasLayer(reports: filteredReports),
                  MarkerLayer(
                    markers: [
                      // User Current Location Pin (Ghaziabad Center)
                      Marker(
                        point: const LatLng(
                          AppConstants.ghaziabadCenterLat,
                          AppConstants.ghaziabadCenterLng,
                        ),
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Incident Spots Markers
                      ...filteredReports.map((report) {
                        final color = _getMarkerColor(report.category);
                        final icon = _getMarkerIcon(report.category);

                        return Marker(
                          point: LatLng(report.lat, report.lng),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showSpotDetails(report),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(icon, color: Colors.white, size: 20),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading map: $err')),
          ),

          // Floating Top Header & Filter Chips
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search & Control Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: AppColors.primaryPurple),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Ghaziabad Safety Heatmap',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        // Heatmap toggle switch
                        InkWell(
                          onTap: () {
                            setState(() => _showHeatmap = !_showHeatmap);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _showHeatmap
                                  ? AppColors.primaryPurpleSurface
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.layers_rounded,
                                  size: 16,
                                  color: _showHeatmap
                                      ? AppColors.primaryPurple
                                      : AppColors.textHintLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _showHeatmap ? 'Heatmap ON' : 'Pins Only',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _showHeatmap
                                        ? AppColors.primaryPurple
                                        : AppColors.textHintLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Category Filter Pills
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() => _selectedCategory = cat);
                            },
                            selectedColor: AppColors.primaryPurpleSurface,
                            checkmarkColor: AppColors.primaryPurple,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primaryPurple
                                  : AppColors.textPrimaryLight,
                            ),
                            backgroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.black12,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Recenter Map Button
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryPurple,
              child: const Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(
                  const LatLng(
                    AppConstants.ghaziabadCenterLat,
                    AppConstants.ghaziabadCenterLng,
                  ),
                  AppConstants.defaultMapZoom,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
