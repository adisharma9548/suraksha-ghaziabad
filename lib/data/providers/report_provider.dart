import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import 'repository_providers.dart';

final allReportsStreamProvider = StreamProvider<List<ReportModel>>((ref) {
  return ref.watch(reportRepositoryProvider).getReportsStream();
});

final myReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  return ref.watch(reportRepositoryProvider).getMyReports();
});

class ReportController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ReportController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> submitReport(ReportModel report) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(reportRepositoryProvider).submitReport(report);
      state = const AsyncValue.data(null);
      _ref.invalidate(myReportsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String adminNote,
  }) async {
    try {
      await _ref.read(reportRepositoryProvider).updateReportStatus(
            reportId: reportId,
            status: status,
            adminNote: adminNote,
          );
      _ref.invalidate(myReportsProvider);
    } catch (_) {}
  }
}

final reportControllerProvider =
    StateNotifierProvider<ReportController, AsyncValue<void>>((ref) {
  return ReportController(ref);
});
