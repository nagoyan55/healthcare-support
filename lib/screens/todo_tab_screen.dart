import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/todo_service.dart';

class TodoTabScreen extends StatefulWidget {
  final String patientId;

  const TodoTabScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<TodoTabScreen> createState() => _TodoTabScreenState();
}

class _TodoTabScreenState extends State<TodoTabScreen> {
  final TodoService _todoService = TodoService();
  List<Map<String, dynamic>> _todos = [];
  final String _currentUserId = 'demo-user';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final todosStream = _todoService.getTodos(widget.patientId);
      todosStream.listen((todos) {
        setState(() {
          _todos = todos;
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TODOリストの取得に失敗しました')),
        );
      }
    }
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();
        DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '新規タスク',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'タイトル',
                    labelStyle: const TextStyle(color: Color(0xFF5F6368)),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '詳細',
                    labelStyle: const TextStyle(color: Color(0xFF5F6368)),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Color(0xFF5F6368),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '期限:',
                          style: TextStyle(
                            color: Color(0xFF5F6368),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              setState(() => selectedDate = date);
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5F6368),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('キャンセル'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          try {
                            await _todoService.addTodo(
                              patientId: widget.patientId,
                              title: titleController.text,
                              description: descriptionController.text,
                              deadline: selectedDate,
                              assignedTo: _currentUserId,
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('タスクの追加に失敗しました')),
                              );
                            }
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('追加'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDeadline(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    _todos.sort((a, b) => (a['deadline'] as Timestamp)
        .toDate()
        .compareTo((b['deadline'] as Timestamp).toDate()));

    return Stack(
      children: [
        Container(
          color: const Color(0xFFF8F9FA),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final todo = _todos[index];
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
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
                                color: todo['isCompleted'] as bool
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primary,
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
                                    Transform.scale(
                                      scale: 1.2,
                                      child: Checkbox(
                                        value: todo['isCompleted'] as bool,
                                        onChanged: (value) async {
                                          try {
                                            await _todoService.updateTodoStatus(
                                              patientId: widget.patientId,
                                              todoId: todo['id'] as String,
                                              isCompleted: value!,
                                            );
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'タスクの状態更新に失敗しました')),
                                              );
                                            }
                                          }
                                        },
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            todo['title'] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              decoration: todo['isCompleted']
                                                      as bool
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: todo['isCompleted'] as bool
                                                  ? Colors.grey
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            todo['description'] as String,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: todo['isCompleted'] as bool
                                                  ? Colors.grey
                                                  : Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F3F4),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '期限: ${_formatDeadline(todo['deadline'] as Timestamp)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
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
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _addTodo,
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.add),
            label: const Text('新規タスク'),
          ),
        ),
      ],
    );
  }
}
