import 'package:flutter/material.dart';
import '../services/ward_service.dart';
import '../widgets/auth_wrapper.dart';

class WardSelectionScreen extends StatefulWidget {
  const WardSelectionScreen({super.key});

  @override
  State<WardSelectionScreen> createState() => _WardSelectionScreenState();
}

class _WardSelectionScreenState extends State<WardSelectionScreen> {
  final WardService _wardService = WardService();
  late Future<List<Map<String, dynamic>>> _wardsFuture;

  @override
  void initState() {
    super.initState();
    _wardsFuture = _wardService.getWards();
  }

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Scaffold(
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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _wardsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('エラーが発生しました: ${snapshot.error}'),
              );
            }

            final wards = snapshot.data!;
            return ListView.builder(
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
                    tileColor:
                        isCurrentWard ? Colors.blue.withOpacity(0.1) : null,
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
            );
          },
        ),
      ),
    );
  }
}
