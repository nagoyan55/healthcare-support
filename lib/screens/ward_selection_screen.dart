import 'package:flutter/material.dart';

class WardSelectionScreen extends StatelessWidget {
  const WardSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> wards = [
      {'id': '1', 'name': '脳神経内科'},
      {'id': '2', 'name': '内科病棟'},
      {'id': '3', 'name': '外科病棟'},
      {'id': '4', 'name': '小児科病棟'},
      {'id': '5', 'name': '産婦人科病棟'},
      {'id': '6', 'name': '精神科病棟'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('病棟選択'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/my_page');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: wards.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final ward = wards[index];
          final isCurrentWard = ward['name'] == '脳神経内科';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(ward['name']!),
              trailing: isCurrentWard
                  ? const Icon(Icons.home, color: Colors.blue)
                  : const Icon(Icons.arrow_forward_ios),
              tileColor: isCurrentWard ? Colors.blue.withOpacity(0.1) : null,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/patient_selection',
                  arguments: ward,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
