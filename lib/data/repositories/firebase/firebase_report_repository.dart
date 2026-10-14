import '../../models/report_model.dart';
import '../abstract/report_repository.dart';

class FirebaseReportRepository implements ReportRepository {
  @override
  Future<List<ReportModel>> getAllReports() async => [];

  @override
  Stream<List<ReportModel>> getReportsStream() => const Stream.empty();

  @override
  Future<List<ReportModel>> getMyReports() async => [];

  @override
  Future<ReportModel> submitReport(ReportModel report) async => report;

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String adminNote,
  }) async {}
}
