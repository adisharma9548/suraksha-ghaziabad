import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';

/// Native iOS Report Unsafe Spot Form
/// Strict Apple HIG grouped inset styling, accessible multi-cue pickers, and color-blind safe severity indicators.
class ReportUnsafeSpotScreen extends ConsumerStatefulWidget {
  const ReportUnsafeSpotScreen({super.key});

  @override
  ConsumerState<ReportUnsafeSpotScreen> createState() =>
      _ReportUnsafeSpotScreenState();
}

class _ReportUnsafeSpotScreenState
    extends ConsumerState<ReportUnsafeSpotScreen> {
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  String _selectedCategory = 'Broken streetlight';
  String _selectedLocality = 'Indirapuram (Kala Patthar Road)';
  double _lat = 28.6432;
  double _lng = 77.3695;
  String _selectedTimeOfDay = 'Night';
  int _severity = 4;
  bool _isAnonymous = true;

  final List<String> _categories = [
    'Broken streetlight',
    'Isolated road',
    'Harassment',
    'Drunk crowd',
    'Other',
  ];

  final Map<String, ({double lat, double lng})> _ghaziabadLocalities = {
    'Indirapuram (Kala Patthar Road)': (lat: 28.6432, lng: 77.3695),
    'Vaishali (Sector 4 Metro Area)': (lat: 28.6478, lng: 77.3392),
    'Raj Nagar (RDC Concrete Market)': (lat: 28.6875, lng: 77.4418),
    'Raj Nagar Extension (Hindon River Road)': (lat: 28.6982, lng: 77.4320),
    'Crossings Republik (NH-24 Service Lane)': (lat: 28.6285, lng: 77.4325),
    'Vasundhara (Sector 14 Drain Road)': (lat: 28.6620, lng: 77.3645),
    'Sahibabad (Site-4 Industrial Area)': (lat: 28.6655, lng: 77.3780),
    'Kaushambi (Central Park East Gate)': (lat: 28.6450, lng: 77.3210),
    'Govindpuram (Anaj Mandi Road)': (lat: 28.6830, lng: 77.5120),
    'Kavi Nagar (Girls College Gate)': (lat: 28.6640, lng: 77.4630),
    'Old Ghaziabad (Railway Station North)': (lat: 28.6660, lng: 77.4285),
    'Vijay Nagar (Bypass Chowk)': (lat: 28.6430, lng: 77.4410),
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Description Required'),
          content: const Text('Please provide specific details about why this area is unsafe.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    final routedAuth = ReportModel.resolveAuthority(_selectedCategory);
    final resolvedWard = ReportModel.resolveWard(_lat, _lng, _selectedLocality);

    final newReport = ReportModel(
      id: _uuid.v4(),
      category: _selectedCategory,
      description: description,
      lat: _lat,
      lng: _lng,
      locationName: _selectedLocality,
      status: 'Open',
      createdAt: DateTime.now(),
      isAnonymous: _isAnonymous,
      severity: _severity,
      timeOfDay: _selectedTimeOfDay,
      routedAuthority: routedAuth,
      acknowledgementStatus: 'Delivered to Control Room',
      wardName: resolvedWard,
    );

    final success =
        await ref.read(reportControllerProvider.notifier).submitReport(newReport);

    if (success && mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Report Submitted'),
          content: Text(
            'Your safety spot was successfully delivered to ${newReport.routedAuthorityLabel}. It is now visible on the live heatmap.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Done'),
              onPressed: () {
                Navigator.pop(ctx);
                _descriptionController.clear();
                setState(() => _severity = 3);
              },
            ),
          ],
        ),
      );
    }
  }

  void _showLocalityPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Cancel', style: IosTypography.body(color: AppColors.secondaryTextDark)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Text('Select Locality', style: IosTypography.headline()),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Done', style: IosTypography.headline(color: AppColors.accentBlue)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 36,
                scrollController: FixedExtentScrollController(
                  initialItem: _ghaziabadLocalities.keys.toList().indexOf(_selectedLocality),
                ),
                onSelectedItemChanged: (index) {
                  final key = _ghaziabadLocalities.keys.toList()[index];
                  setState(() {
                    _selectedLocality = key;
                    final coords = _ghaziabadLocalities[key]!;
                    _lat = coords.lat;
                    _lng = coords.lng;
                  });
                },
                children: _ghaziabadLocalities.keys.map((loc) {
                  return Center(
                    child: Text(
                      loc,
                      style: IosTypography.callout(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reportState = ref.watch(reportControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text(l10n.reportTitle, style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Inset Section 1: Location & Coordinates
              IosGroupedSection(
                header: 'LOCATION IN GHAZIABAD',
                footer: 'Precise coordinates will be mapped and monitored by civic authorities.',
                children: [
                  IosListTile(
                    leadingIcon: CupertinoIcons.location_solid,
                    title: 'Spot Locality',
                    subtitle: _selectedLocality,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change',
                          style: IosTypography.subhead(color: AppColors.accentBlue),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                    onTap: _showLocalityPicker,
                  ),
                ],
              ),

              // Inset Section 2: Incident Category & Routed Authority
              IosGroupedSection(
                header: 'CATEGORY & CIVIC ROUTING',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((cat) {
                            final isSelected = cat == _selectedCategory;
                            return CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 34,
                              onPressed: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryTextColor
                                      : (isDark ? AppColors.surfaceDark : AppColors.secondaryBackgroundLight),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryTextColor
                                        : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
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
                                      const SizedBox(width: 6),
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
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        // Authority routing card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.secondaryBackgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                ReportModel.resolveAuthority(_selectedCategory) == 'NAGAR_NIGAM_GHAZIABAD'
                                    ? CupertinoIcons.building_2_fill
                                    : CupertinoIcons.shield_lefthalf_fill,
                                size: 18,
                                color: primaryTextColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Queue: ${ReportModel.resolveAuthority(_selectedCategory) == 'NAGAR_NIGAM_GHAZIABAD' ? 'Nagar Nigam Ghaziabad (Lighting/Civic)' : 'UP Police Ghaziabad (Patrol & Law)'}',
                                  style: IosTypography.caption1(
                                    color: primaryTextColor,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Inset Section 3: Time of Occurrence & Severity
              IosGroupedSection(
                header: 'TIMING & HAZARD SEVERITY',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time of Occurrence', style: IosTypography.subhead(color: secondaryTextColor)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Morning', 'Afternoon', 'Evening', 'Night'].map((time) {
                            final isSelected = time == _selectedTimeOfDay;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 34,
                                  onPressed: () => setState(() => _selectedTimeOfDay = time),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryTextColor
                                          : (isDark ? AppColors.surfaceDark : AppColors.secondaryBackgroundLight),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? primaryTextColor : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      time,
                                      style: IosTypography.caption1(
                                        color: isSelected
                                            ? (isDark ? Colors.black : Colors.white)
                                            : primaryTextColor,
                                        weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Severity Level', style: IosTypography.subhead(color: secondaryTextColor)),
                            IosBadge(
                              label: 'Level $_severity / 5',
                              icon: _severity >= 4
                                  ? CupertinoIcons.exclamationmark_triangle_fill
                                  : CupertinoIcons.info_circle_fill,
                              type: _severity >= 4 ? IosBadgeType.error : IosBadgeType.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: primaryTextColor,
                            inactiveTrackColor: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            thumbColor: primaryTextColor,
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _severity.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (val) => setState(() => _severity = val.round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Inset Section 4: Details & Privacy
              IosGroupedSection(
                header: 'DESCRIPTION & PRIVACY',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: CupertinoTextField(
                      controller: _descriptionController,
                      placeholder: 'Describe the risk (e.g., lights out for 2 weeks, no street patrols)...',
                      placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                      style: IosTypography.callout(color: primaryTextColor),
                      maxLines: 3,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondaryBackgroundLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                        ),
                      ),
                    ),
                  ),
                  IosListTile(
                    leadingIcon: CupertinoIcons.eye_slash_fill,
                    title: 'Anonymous Report',
                    subtitle: 'Hides your name and phone number from officers',
                    trailing: CupertinoSwitch(
                      value: _isAnonymous,
                      activeColor: primaryTextColor,
                      onChanged: (val) => setState(() => _isAnonymous = val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Submit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IosButton(
                  text: 'Submit Unsafe Spot Report',
                  icon: CupertinoIcons.paperplane_fill,
                  isLoading: reportState.isLoading,
                  onPressed: _handleSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
