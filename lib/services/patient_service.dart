import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 患者の基本情報を取得
  Future<Map<String, dynamic>?> getPatientBasicInfo(String patientId) async {
    try {
      final doc = await _firestore.collection('patients').doc(patientId).get();
      return doc.data()?['basicInfo'];
    } catch (e) {
      log('Error getting patient basic info: $e');
      return null;
    }
  }

  // 患者の既往歴を取得
  Future<List<Map<String, dynamic>>> getMedicalHistory(String patientId) async {
    try {
      final doc = await _firestore.collection('patients').doc(patientId).get();
      final List<dynamic> history = doc.data()?['medicalHistory'] ?? [];
      return history.cast<Map<String, dynamic>>();
    } catch (e) {
      log('Error getting medical history: $e');
      return [];
    }
  }

  // 患者の現病歴を取得・更新
  Future<String?> getCurrentCondition(String patientId) async {
    try {
      final doc = await _firestore.collection('patients').doc(patientId).get();
      return doc.data()?['currentCondition'];
    } catch (e) {
      log('Error getting current condition: $e');
      return null;
    }
  }

  Future<void> updateCurrentCondition(
      String patientId, String condition) async {
    try {
      await _firestore.collection('patients').doc(patientId).update({
        'currentCondition': condition,
      });
    } catch (e) {
      log('Error updating current condition: $e');
      throw '現病歴の更新に失敗しました';
    }
  }

  // 電子カルテ情報を検索
  Future<List<Map<String, dynamic>>> searchMedicalRecords(
    String patientId,
    String keyword,
  ) async {
    try {
      // 注: 実際の実装では、電子カルテシステムのAPIを使用する必要があります
      final snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medicalRecords')
          .where('content', isGreaterThanOrEqualTo: keyword)
          .where('content', isLessThanOrEqualTo: '$keyword\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      log('Error searching medical records: $e');
      return [];
    }
  }

  // 病棟の患者一覧を取得(担当ナース情報付き)
  Future<List<Map<String, dynamic>>> getPatientsByWard(String ward,
      {String? nurseId}) async {
    try {
      // まず病棟の患者を取得
      final patientsSnapshot = await _firestore
          .collection('patients')
          .where('basicInfo.ward', isEqualTo: ward)
          .get();

      // 全ての担当ナース情報を取得
      final assignedPatientsSnapshot =
          await _firestore.collection('assigned_patients').get();

      // 患者IDごとの担当ナース情報をマッピング
      Map<String, List<Map<String, dynamic>>> assignedNurses = {};

      for (var doc in assignedPatientsSnapshot.docs) {
        final nurseId = doc.id;
        final data = doc.data();
        final patients = data['patients'] as List;

        // ナースの情報を取得
        final nurseDoc =
            await _firestore.collection('users').doc(nurseId).get();

        if (!nurseDoc.exists) continue;
        final nurseData = nurseDoc.data()!;

        // 各患者に対して担当ナース情報を追加
        for (var patient in patients) {
          final patientId = patient['patientId'] as String;
          if (!assignedNurses.containsKey(patientId)) {
            assignedNurses[patientId] = [];
          }
          assignedNurses[patientId]!.add({
            'id': nurseId,
            'name': nurseData['name'],
            'assignedAt': patient['assignedAt'],
            'isCurrentUser': doc.id == nurseId
          });
        }
      }

      // 患者情報に担当ナース情報を付加
      return patientsSnapshot.docs.map((doc) {
        final data = doc.data();
        final patientId = doc.id;
        final patientNurses = assignedNurses[patientId] ?? [];

        return <String, dynamic>{
          'id': patientId,
          ...Map<String, dynamic>.from(data['basicInfo'] as Map),
          'assignedNurses': patientNurses,
          'isAssigned': nurseId != null &&
              patientNurses.any((nurse) => nurse['id'] == nurseId),
        };
      }).toList();
    } catch (e) {
      log('Error getting patients by ward: $e');
      return [];
    }
  }

  // 患者の最新のバイタルサインを取得
  Future<Map<String, dynamic>?> getLatestVitals(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('vitals')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      return {
        'id': snapshot.docs.first.id,
        ...data,
      };
    } catch (e) {
      log('Error getting latest vitals: $e');
      return null;
    }
  }

  // 患者の処方情報を取得
  Future<List<Map<String, dynamic>>> getPrescriptions(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('prescriptions')
          .orderBy('prescribedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      log('Error getting prescriptions: $e');
      return [];
    }
  }
}
