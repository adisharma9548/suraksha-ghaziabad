import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the unsafe spot condition')),
      );
      return;
    }

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
    );

    final success =
        await ref.read(reportControllerProvider.notifier).submitReport(newReport);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully! Added to live district heatmap.'),
          backgroundColor: AppColors.safeGreen,
        ),
      );
      _descriptionController.clear();
      setState(() {
        _severity = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reportState = ref.watch(reportControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ghaziabad Location Selector
              Text(
                l10n.pickOnMap,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocality,
                isExpanded: true,
                items: _ghaziabadLocalities.keys.map((loc) {
                  return DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedLocality = val;
                      final coords = _ghaziabadLocalities[val]!;
                      _lat = coords.lat;
                      _lng = coords.lng;
                    });
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryPurple),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector
              Text(
                l10n.selectCategory,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryPurpleSurface,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.textPrimaryLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Time of Day
              const Text(
                'Time of Occurrence',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Morning', 'Afternoon', 'Evening', 'Night'].map((time) {
                  final isSelected = time == _selectedTimeOfDay;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppColors.primaryPurpleSurface
                              : Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : AppColors.dividerLight,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: () => setState(() => _selectedTimeOfDay = time),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryPurple
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Severity Level Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hazard Severity Level',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Level $_severity / 5',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _severity >= 4 ? AppColors.sosRed : AppColors.warningAmberDark,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _severity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: _severity >= 4 ? AppColors.sosRed : AppColors.primaryPurple,
                onChanged: (val) => setState(() => _severity = val.round()),
              ),
              const SizedBox(height: 12),

              // Description Field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.descriptionLabel,
                  hintText: l10n.descriptionHint,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Anonymous by Default Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isAnonymous,
                activeColor: AppColors.primaryPurple,
                title: Text(
                  l10n.anonymousToggle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  l10n.anonymousNote,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                onChanged: (val) => setState(() => _isAnonymous = val),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: reportState.isLoading ? null : _handleSubmit,
                child: reportState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.submit),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
