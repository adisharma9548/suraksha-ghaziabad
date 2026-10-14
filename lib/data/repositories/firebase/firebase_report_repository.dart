import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../models/report_model.dart';
import '../abstract/report_repository.dart';

class FirebaseReportRepository implements ReportRepository {
  final FirebaseFirestore? firestore;
  final FirebaseStorage? storage;

  final List<ReportModel> _cachedReports = [];

  FirebaseReportRepository({
    this.firestore,
    this.storage,
  });

  bool get _isFirebaseAvailable => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;
  FirebaseStorage get _effectiveStorage =>
      storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _reportsCol =>
      _effectiveFirestore.collection('reports');

  @override
  Future<List<ReportModel>> getAllReports() async {
    if (_isFirebaseAvailable) {
      try {
        final snapshot = await _reportsCol
            .orderBy('createdAt', descending: true)
            .get();

        final reports = snapshot.docs
            .map((doc) => ReportModel.fromJson(doc.data()))
            .toList();

        _cachedReports.clear();
        _cachedReports.addAll(reports);
        return List.unmodifiable(_cachedReports);
      } catch (e) {
        debugPrint('FirebaseReportRepository.getAllReports error: $e');
      }
    }
    return List.unmodifiable(_cachedReports);
  }

  @override
  Stream<List<ReportModel>> getReportsStream() {
    if (_isFirebaseAvailable) {
      return _reportsCol
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final reports = snapshot.docs
                .map((doc) => ReportModel.fromJson(doc.data()))
                .toList();
            _cachedReports.clear();
            _cachedReports.addAll(reports);
            return reports;
          });
    }

    return Stream.value(List.unmodifiable(_cachedReports));
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    return getAllReports();
  }

  @override
  Future<ReportModel> submitReport(ReportModel report) async {
    String? uploadedPhotoUrl = report.photoUrl;

    if (_isFirebaseAvailable &&
        report.photoUrl != null &&
        report.photoUrl!.isNotEmpty &&
        !report.photoUrl!.startsWith('http')) {
      try {
        final file = File(report.photoUrl!);
        if (await file.exists()) {
          final storageRef = _effectiveStorage
              .ref()
              .child('reports')
              .child('${report.id}.jpg');
          final uploadTask = await storageRef.putFile(file);
          uploadedPhotoUrl = await uploadTask.ref.getDownloadURL();
        }
      } catch (e) {
        debugPrint('FirebaseReportRepository photo upload error: $e');
      }
    }

    final finalReport = report.copyWith(photoUrl: uploadedPhotoUrl);
    _cachedReports.insert(0, finalReport);

    if (_isFirebaseAvailable) {
      try {
        await _reportsCol.doc(finalReport.id).set(finalReport.toJson());
      } catch (e) {
        debugPrint('FirebaseReportRepository.submitReport error: $e');
      }
    }

    return finalReport;
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String adminNote,
    String? acknowledgementStatus,
  }) async {
    final effectiveAck = acknowledgementStatus ??
        (status == 'Fixed'
            ? 'Fixed'
            : (status == 'In progress'
                ? 'Action In Progress'
                : 'Acknowledged by Control Room'));

    final index = _cachedReports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _cachedReports[index] = _cachedReports[index].copyWith(
        status: status,
        adminNote: adminNote,
        acknowledgementStatus: effectiveAck,
      );
    }

    if (_isFirebaseAvailable) {
      try {
        await _reportsCol.doc(reportId).update({
          'status': status,
          'adminNote': adminNote,
          'acknowledgementStatus': effectiveAck,
        });
      } catch (e) {
        debugPrint('FirebaseReportRepository.updateReportStatus error: $e');
      }
    }
  }
}
