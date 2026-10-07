import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/critical_record.dart';

class CriticalRecordRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRecord(CriticalRecord record) async {
    await _firestore.collection('critical_records').add(record.toMap());
  }

  Future<List<CriticalRecord>> getRecentRecords() async {
    final query = await _firestore
        .collection('critical_records')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return query.docs
        .map((doc) => CriticalRecord.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<CriticalRecord>> searchRecords({
    String? name,
    int? age,
    String? campId,
    CriticalRecordStatus? status,
  }) async {
    final snapshot = await _firestore.collection('critical_records').get();
    var records = snapshot.docs
        .map((doc) => CriticalRecord.fromMap(doc.id, doc.data()))
        .toList();

    if (name != null && name.trim().isNotEmpty) {
      final searchName = name.trim().toLowerCase();
      records = records
          .where((record) => record.name.toLowerCase().contains(searchName))
          .toList();
    }

    // Local filtering to avoid immediate composite index requirements
    if (age != null) {
      records = records.where((r) => r.age == age).toList();
    }

    if (campId != null) {
      records = records.where((r) => r.campId == campId).toList();
    }

    if (status != null) {
      records = records.where((r) => r.status == status).toList();
    }

    // Sort by newest
    records.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    return records;
  }

  Future<void> updateStatus(
    String recordId,
    CriticalRecordStatus newStatus,
  ) async {
    await _firestore.collection('critical_records').doc(recordId).update({
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<CriticalRecord?> getRecordById(String id) async {
    final doc = await _firestore.collection('critical_records').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return CriticalRecord.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
