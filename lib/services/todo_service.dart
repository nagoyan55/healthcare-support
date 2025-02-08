import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TODOリストを取得
  Stream<List<Map<String, dynamic>>> getTodos(String patientId) {
    return _firestore
        .collection('todos')
        .doc(patientId)
        .collection('tasks')
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // 新しいTODOを追加
  Future<void> addTodo({
    required String patientId,
    required String title,
    required String description,
    required DateTime deadline,
    required String assignedTo,
  }) async {
    try {
      final todoData = {
        'title': title,
        'description': description,
        'deadline': Timestamp.fromDate(deadline),
        'assignedTo': assignedTo,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('todos')
          .doc(patientId)
          .collection('tasks')
          .add(todoData);
    } catch (e) {
      log('Error adding todo: $e');
      throw 'タスクの追加に失敗しました';
    }
  }

  // TODOの完了状態を更新
  Future<void> updateTodoStatus({
    required String patientId,
    required String todoId,
    required bool isCompleted,
  }) async {
    try {
      await _firestore
          .collection('todos')
          .doc(patientId)
          .collection('tasks')
          .doc(todoId)
          .update({
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      log('Error updating todo status: $e');
      throw 'タスクの状態更新に失敗しました';
    }
  }

  // TODOを更新
  Future<void> updateTodo({
    required String patientId,
    required String todoId,
    String? title,
    String? description,
    DateTime? deadline,
    String? assignedTo,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (deadline != null) updates['deadline'] = Timestamp.fromDate(deadline);
      if (assignedTo != null) updates['assignedTo'] = assignedTo;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('todos')
          .doc(patientId)
          .collection('tasks')
          .doc(todoId)
          .update(updates);
    } catch (e) {
      log('Error updating todo: $e');
      throw 'タスクの更新に失敗しました';
    }
  }

  // TODOを削除
  Future<void> deleteTodo({
    required String patientId,
    required String todoId,
  }) async {
    try {
      await _firestore
          .collection('todos')
          .doc(patientId)
          .collection('tasks')
          .doc(todoId)
          .delete();
    } catch (e) {
      log('Error deleting todo: $e');
      throw 'タスクの削除に失敗しました';
    }
  }

  // 期限切れのTODOを取得
  Future<List<Map<String, dynamic>>> getOverdueTodos(String patientId) async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final snapshot = await _firestore
          .collection('todos')
          .doc(patientId)
          .collection('tasks')
          .where('deadline', isLessThan: now)
          .where('isCompleted', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      log('Error getting overdue todos: $e');
      return [];
    }
  }

  // 担当者のTODOをストリームで取得
  Stream<List<Map<String, dynamic>>> getTodosByAssigneeStream(String userId) {
    return _firestore
        .collectionGroup('tasks')
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final todos = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final patientId = doc.reference.parent.parent!.id;
        todos.add({
          'id': doc.id,
          'patientId': patientId,
          ...data,
        });
      }
      return todos
        ..sort((a, b) =>
            (a['deadline'] as Timestamp).compareTo(b['deadline'] as Timestamp));
    });
  }

  // 担当者のTODOを一括取得
  Future<List<Map<String, dynamic>>> getTodosByAssignee(String userId) async {
    try {
      // 全患者のTODOコレクションから担当者のタスクを検索
      final patientsSnapshot = await _firestore.collection('patients').get();
      final allTodos = await Future.wait(
        patientsSnapshot.docs.map((patientDoc) async {
          final todosSnapshot = await _firestore
              .collection('todos')
              .doc(patientDoc.id)
              .collection('tasks')
              .where('assignedTo', isEqualTo: userId)
              .where('isCompleted', isEqualTo: false)
              .get();

          return todosSnapshot.docs.map((doc) {
            final data = doc.data();
            return <String, dynamic>{
              'id': doc.id,
              'patientId': patientDoc.id,
              ...data,
            };
          }).toList();
        }),
      );

      // 全患者のTODOを1つのリストにフラット化
      return allTodos.expand((todos) => todos).toList()
        ..sort((a, b) =>
            (a['deadline'] as Timestamp).compareTo(b['deadline'] as Timestamp));
    } catch (e) {
      log('Error getting todos by assignee: $e');
      return [];
    }
  }
}
