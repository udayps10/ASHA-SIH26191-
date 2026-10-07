import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/normal_record.dart';

class NormalRecordRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRecord(NormalRecord record) async {
    await _firestore.collection('normal_records').add(record.toMap());
  }

  Future<List<NormalRecord>> getRecentRecords() async {
    final query = await _firestore
        .collection('normal_records')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return query.docs
        .map((doc) => NormalRecord.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<NormalRecord>> searchRecords({
    String? name,
    int? age,
    String? campId,
    NormalRecordStatus? status,
  }) async {
    // To avoid complex composite index requirements in the prototype,
    // we query primarily by name or just fetch all and filter locally.

    final snapshot = await _firestore.collection('normal_records').get();
    var records = snapshot.docs
        .map((doc) => NormalRecord.fromMap(doc.id, doc.data()))
        .toList();

    if (name != null && name.trim().isNotEmpty) {
      final searchName = name.trim().toLowerCase();
      records = records
          .where((record) => record.name.toLowerCase().contains(searchName))
          .toList();
    }

    // Secondary filtering performed locally to avoid "Query requires an index" error
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
    NormalRecordStatus newStatus,
  ) async {
    await _firestore.collection('normal_records').doc(recordId).update({
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<NormalRecord?> getRecordById(String id) async {
    final doc = await _firestore.collection('normal_records').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return NormalRecord.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
