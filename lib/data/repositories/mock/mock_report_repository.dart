import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/report_model.dart';
import '../abstract/report_repository.dart';

class MockReportRepository implements ReportRepository {
  final List<ReportModel> _reports = [];
  final List<ReportModel> _userReports = [];
  final _reportsController = StreamController<List<ReportModel>>.broadcast();
  final _uuid = const Uuid();

  MockReportRepository([List<ReportModel>? initialReports]) {
    if (initialReports != null) {
      _reports.addAll(initialReports);
    }
  }

  @override
  Future<List<ReportModel>> getAllReports() async {
    return List.unmodifiable(_reports);
  }

  @override
  Stream<List<ReportModel>> getReportsStream() {
    Future.microtask(() {
      _reportsController.add(List.unmodifiable(_reports));
    });
    return _reportsController.stream;
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    return List.unmodifiable(_userReports);
  }

  @override
  Future<ReportModel> submitReport(ReportModel report) async {
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
