import 'package:flutter/material.dart';
import '../../services/todo_service.dart';
import '../../widgets/todo_list.dart';

class TaskTab extends StatefulWidget {
  const TaskTab({super.key});

  @override
  State<TaskTab> createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> {
  final TodoService _todoService = TodoService();
  final String _currentUserId = 'demo-user'; // TODO: 認証から取得

  @override
  Widget build(BuildContext context) {
    return TodoList(
      todoStream: _todoService.getTodosByAssigneeStream(_currentUserId),
    );
  }
}
