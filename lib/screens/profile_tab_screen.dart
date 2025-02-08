import 'package:flutter/material.dart';
import '../services/patient_service.dart';

class ProfileTabScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ProfileTabScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final TextEditingController _presentIllnessController =
      TextEditingController();
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _medicalHistory = [];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    _presentIllnessController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    try {
      final history =
          await _patientService.getMedicalHistory(widget.patient['id']!);
      final condition =
          await _patientService.getCurrentCondition(widget.patient['id']!);
      setState(() {
        _medicalHistory = history;
        if (condition != null) {
          _presentIllnessController.text = condition;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('患者データの取得に失敗しました')),
        );
      }
    }
  }

  Future<void> _updateCurrentCondition() async {
    try {
      await _patientService.updateCurrentCondition(
        widget.patient['id']!,
        _presentIllnessController.text,
      );
      
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('現病歴を更新しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('現病歴の更新に失敗しました')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本情報カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本情報',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: widget.patient['gender'] == 'M'
                            ? Colors.blue
                            : Colors.pink,
                      ),
                      title: const Text('氏名'),
                      subtitle: Text(widget.patient['name']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.room),
                      title: const Text('病室'),
                      subtitle: Text(
                          '${widget.patient['room']}号室 ${widget.patient['bed']}床'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.numbers),
                      title: const Text('患者ID'),
                      subtitle: Text(widget.patient['id']!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 既往歴カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '既往歴',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ..._medicalHistory.map((history) => Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.medical_information),
                              title: Text(history['condition'] as String),
                              subtitle: Text(history['details'] as String),
                            ),
                            if (_medicalHistory.last != history)
                              const Divider(),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 現病歴カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '現病歴',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _presentIllnessController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '現病歴を入力してください',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _updateCurrentCondition,
                      child: const Text('更新する'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI要約:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<String?>(
                      stream: _patientService.getPatientSummaryStream(widget.patient['id']!),
                      builder: (context, snapshot) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: snapshot.hasData && snapshot.data != null
                              ? Text(
                                  snapshot.data!,
                                  style: const TextStyle(height: 1.5),
                                )
                              : const Text(
                                  '現病歴を更新すると、AI要約が生成されます',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 電子カルテ内検索カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '電子カルテ内検索',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'キーワードを入力して検索',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) async {
                        if (value.length >= 2) {
                          try {
                            final records =
                                await _patientService.searchMedicalRecords(
                              widget.patient['id']!,
                              value,
                            );
                            setState(() {
                              _searchResults = records;
                            });
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('検索に失敗しました')),
                              );
                            }
                          }
                        } else {
                          setState(() {
                            _searchResults = [];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ..._searchResults.map((record) => Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.article),
                              title: Text(record['title'] as String),
                              subtitle: Text(record['content'] as String),
                            ),
                            if (_searchResults.last != record) const Divider(),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
