import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/patient_service.dart';
import '../widgets/auth_wrapper.dart';
import '../providers/patient_provider.dart';

class PatientSelectionScreen extends ConsumerStatefulWidget {
  const PatientSelectionScreen({super.key});

  @override
  ConsumerState<PatientSelectionScreen> createState() => _PatientSelectionScreenState();
}

class _PatientSelectionScreenState extends ConsumerState<PatientSelectionScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PatientService _patientService = PatientService();

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? selectedWard =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    // 病棟が選択されていない場合
    if (selectedWard == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/ward_selection');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AuthWrapper(
      child: _buildContent(selectedWard),
    );
  }

  Widget _buildContent(Map<String, String> selectedWard) {
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadScreenData(selectedWard),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final userData = data['userData'] as Map<String, dynamic>;
          final patients = data['patients'] as List<Map<String, dynamic>>;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '担当ナース: ${userData['name']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '病棟患者総数: ${patients.length}名',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '受け持ち患者数: ${patients.where((p) => p['isAssigned']).length}名',
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
                    final isAssigned = patient['isAssigned'] as bool;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: patient['gender'] == 'M'
                              ? Colors.blue
                              : Colors.pink,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(patient['name']!),
                        subtitle:
                            Text('${patient['room']}号室 ${patient['bed']}床'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if ((patient['assignedNurses'] as List)
                                .isNotEmpty) ...[
                              Tooltip(
                                message:
                                    '担当: ${(patient['assignedNurses'] as List).map((nurse) => nurse['name']).join(', ')}',
                                child: Badge(
                                  label: Text(
                                    (patient['assignedNurses'] as List)
                                        .length
                                        .toString(),
                                  ),
                                  child: Icon(
                                    Icons.people,
                                    color:
                                        isAssigned ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                        onTap: () {
                          // プロバイダーに患者情報を設定
                          ref.read(currentPatientProvider.notifier).setPatient(patient);
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
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadScreenData(Map<String, String> selectedWard) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('ユーザーが見つかりません');
    }

    final userData = await _userService.getUserData(currentUser.uid);
    if (userData == null) {
      throw Exception('ユーザー情報が見つかりません');
    }

    final patients = await _patientService.getPatientsByWard(
      selectedWard['id']!,
      nurseId: currentUser.uid,
    );

    return {
      'userData': userData,
      'patients': patients,
    };
  }
}
