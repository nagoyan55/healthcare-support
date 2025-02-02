import 'package:flutter/material.dart';

class PatientSelectionScreen extends StatelessWidget {
  const PatientSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> selectedWard =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    final List<Map<String, String>> patients = [
      {'id': 'A', 'name': '山田 太郎', 'room': '101', 'bed': 'A', 'gender': 'M'},
      {'id': 'F', 'name': '鈴木 花子', 'room': '101', 'bed': 'B', 'gender': 'F'},
      {'id': 'M', 'name': '佐藤 次郎', 'room': '102', 'bed': 'A', 'gender': 'M'},
      {'id': 'K', 'name': '田中 美咲', 'room': '102', 'bed': 'B', 'gender': 'F'},
      {'id': 'J', 'name': '伊藤 健一', 'room': '103', 'bed': 'A', 'gender': 'M'},
      {'id': 'L', 'name': '高橋 優子', 'room': '103', 'bed': 'B', 'gender': 'F'},
      {'id': 'V', 'name': '渡辺 隆', 'room': '104', 'bed': 'A', 'gender': 'M'},
      {'id': 'R', 'name': '小林 明', 'room': '104', 'bed': 'B', 'gender': 'M'},
      {'id': 'C', 'name': '中村 幸子', 'room': '105', 'bed': 'A', 'gender': 'F'},
      {'id': 'D', 'name': '加藤 健一', 'room': '105', 'bed': 'B', 'gender': 'M'},
      {'id': 'E', 'name': '吉田 直樹', 'room': '106', 'bed': 'A', 'gender': 'M'},
      {'id': 'G', 'name': '山本 美咲', 'room': '106', 'bed': 'B', 'gender': 'F'},
      {'id': 'H', 'name': '佐々木 健', 'room': '107', 'bed': 'A', 'gender': 'M'},
      {'id': 'I', 'name': '井上 花子', 'room': '107', 'bed': 'B', 'gender': 'F'},
      {'id': 'N', 'name': '木村 太一', 'room': '108', 'bed': 'A', 'gender': 'M'},
      {'id': 'O', 'name': '林 明美', 'room': '108', 'bed': 'B', 'gender': 'F'},
      {'id': 'P', 'name': '斎藤 健二', 'room': '109', 'bed': 'A', 'gender': 'M'},
      {'id': 'Q', 'name': '清水 さくら', 'room': '109', 'bed': 'B', 'gender': 'F'},
      {'id': 'S', 'name': '山下 隆史', 'room': '110', 'bed': 'A', 'gender': 'M'},
      {'id': 'T', 'name': '松本 恵子', 'room': '110', 'bed': 'B', 'gender': 'F'},
    ];

    final assignedPatients = ['A', 'F', 'M', 'K', 'J', 'L', 'V', 'R'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedWard['name']} - 患者一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/my_page');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '担当ナース: 社畜',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '病棟患者総数: ${patients.length}名',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '受け持ち患者数: ${assignedPatients.length}名',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: patients.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final patient = patients[index];
                final isAssigned = assignedPatients.contains(patient['id']);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: patient['gender'] == 'M' ? Colors.blue : Colors.pink,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(patient['name']!),
                    subtitle: Text('${patient['room']}号室 ${patient['bed']}床'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAssigned ? Icons.check_circle : Icons.add_circle_outline,
                          color: isAssigned ? Colors.blue : Colors.grey,
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/patient_detail',
                        arguments: patient,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
