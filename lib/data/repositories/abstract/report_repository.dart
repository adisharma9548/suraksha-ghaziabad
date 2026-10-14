import '../../models/report_model.dart';

abstract class ReportRepository {
  Future<List<ReportModel>> getAllReports();
  Stream<List<ReportModel>> getReportsStream();
  Future<List<ReportModel>> getMyReports();
  Future<ReportModel> submitReport(ReportModel report);
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String adminNote,
    String? acknowledgementStatus,
  });
}
