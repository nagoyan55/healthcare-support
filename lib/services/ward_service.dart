import 'package:cloud_firestore/cloud_firestore.dart';

class WardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getWards() async {
    try {
      final snapshot = await _firestore.collection('wards').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] as String,
        };
      }).toList();
    } catch (e) {
      print('Error getting wards: $e');
      return [];
    }
  }
}
