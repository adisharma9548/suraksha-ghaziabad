import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../models/report_model.dart';
import '../abstract/report_repository.dart';

class MockReportRepository implements ReportRepository {
  final List<ReportModel> _reports = [];
  final List<ReportModel> _userReports = [];
  final _reportsController = StreamController<List<ReportModel>>.broadcast();
  bool _isInitialized = false;
  final _uuid = const Uuid();

  MockReportRepository();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/ghaziabad_seed_data.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final rawList = data['unsafe_reports'] as List;
      _reports.clear();
      for (final item in rawList) {
        _reports.add(ReportModel.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {
      // Fallback if bundle load fails
    }
    _isInitialized = true;
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    await _ensureInitialized();
    return List.unmodifiable(_reports);
  }

  @override
  Stream<List<ReportModel>> getReportsStream() {
    _ensureInitialized().then((_) {
      _reportsController.add(List.unmodifiable(_reports));
    });
    return _reportsController.stream;
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    await _ensureInitialized();
    return List.unmodifiable(_userReports);
  }

  @override
  Future<ReportModel> submitReport(ReportModel report) async {
    await _ensureInitialized();
    final newReport = report.copyWith(
      id: report.id.isEmpty ? _uuid.v4() : report.id,
      createdAt: DateTime.now(),
    );

    _reports.insert(0, newReport);
    _userReports.insert(0, newReport);
    _reportsController.add(List.unmodifiable(_reports));
    return newReport;
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String adminNote,
  }) async {
    await _ensureInitialized();
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final updated = _reports[index].copyWith(
        status: status,
        adminNote: adminNote,
      );
      _reports[index] = updated;

      final userIndex = _userReports.indexWhere((r) => r.id == reportId);
      if (userIndex != -1) {
        _userReports[userIndex] = updated;
      }

      _reportsController.add(List.unmodifiable(_reports));
    }
  }
}
