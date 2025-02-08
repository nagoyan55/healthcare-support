import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/todo_service.dart';
import 'todo_checkbox.dart';

class TodoList extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> todoStream;
  final bool showAddButton;
  final String? patientId;
  final VoidCallback? onAddPressed;

  const TodoList({
    super.key,
    required this.todoStream,
    this.showAddButton = false,
    this.patientId,
    this.onAddPressed,
  }) : assert(!showAddButton || (showAddButton && patientId != null) || (showAddButton && onAddPressed != null));

  String _formatDeadline(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final isToday = date.year == now.year && 
                    date.month == now.month && 
                    date.day == now.day;
    final isTomorrow = date.year == now.year && 
                      date.month == now.month && 
                      date.day == now.day + 1;

    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (isToday) {
      return '今日 $timeStr';
    } else if (isTomorrow) {
      return '明日 $timeStr';
    } else {
      return '${date.month}/${date.day} $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFFAFAFA),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: todoStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('エラーが発生しました: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('タスクがありません'));
              }

              final todos = snapshot.data!;
              final incompleteTodos = todos.where((todo) => !todo['isCompleted']).toList();
              final completedTodos = todos.where((todo) => todo['isCompleted']).toList();

              // 日付でソート
              incompleteTodos.sort((a, b) => (a['deadline'] as Timestamp)
                  .toDate()
                  .compareTo((b['deadline'] as Timestamp).toDate()));
              completedTodos.sort((a, b) => (b['deadline'] as Timestamp)
                  .toDate()
                  .compareTo((a['deadline'] as Timestamp).toDate()));

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 未完了のタスク
                  ...incompleteTodos.map((todo) => _buildTodoItem(context, todo)),
                  
                  // 完了済みタスクのセクション
                  if (completedTodos.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        '完了済みのタスク',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...completedTodos.map((todo) => _buildTodoItem(context, todo)),
                  ],
                ],
              );
            },
          ),
        ),
        if (showAddButton)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('新規タスク'),
            ),
          ),
      ],
    );
  }

  Widget _buildTodoItem(BuildContext context, Map<String, dynamic> todo) {
    final isCompleted = todo['isCompleted'] as bool;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final lighterPrimary = HSLColor.fromColor(primaryColor).withLightness(0.7).toColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomLeft: Radius.circular(8.0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TodoCheckbox(
                            key: ValueKey(todo['id']),
                            initialValue: isCompleted,
                            onChanged: (value) async {
                              final todoId = todo['id'] as String?;
                              final todoPatientId = todo['patientId'] as String?;
                              final currentPatientId = patientId;
                              
                              // 個別の患者ページの場合は現在の患者ID、一覧の場合はタスクの患者IDを使用
                              final targetPatientId = currentPatientId ?? todoPatientId;
                              
                              if (targetPatientId == null || todoId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('タスクの情報が不正です'),
                                  ),
                                );
                                return;
                              }

                              log('Updating todo status: patientId=$targetPatientId, todoId=$todoId, value=$value');

                              try {
                                await TodoService().updateTodoStatus(
                                  patientId: targetPatientId,
                                  todoId: todoId,
                                  isCompleted: value,
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('タスクの状態更新に失敗しました: $e'),
                                    backgroundColor: Colors.red[700],
                                  ),
                                );
                                log('Error updating todo status: $e');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todo['title'] as String? ?? '不明なタスク',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: isCompleted
                                        ? Colors.grey[500]
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  todo['description'] as String? ?? '説明なし',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isCompleted
                                        ? Colors.grey[500]
                                        : Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '期限: ${_formatDeadline(todo['deadline'] as Timestamp)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCompleted
                                          ? Colors.grey[500]
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
