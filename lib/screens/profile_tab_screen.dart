import 'package:flutter/material.dart';

class ProfileTabScreen extends StatefulWidget {
  final Map<String, String> patient;

  const ProfileTabScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final TextEditingController _presentIllnessController = TextEditingController();
  String _summarizedIllness = '';

  @override
  void dispose() {
    _presentIllnessController.dispose();
    super.dispose();
  }

  void _summarizeIllness() {
    setState(() {
      _summarizedIllness = _presentIllnessController.text.length > 100
          ? '${_presentIllnessController.text.substring(0, 100)}...'
          : _presentIllnessController.text;
    });
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
                    const ListTile(
                      leading: Icon(Icons.medical_information),
                      title: Text('高血圧'),
                      subtitle: Text('2020年4月より服薬治療中'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.medical_information),
                      title: Text('糖尿病'),
                      subtitle: Text('2021年8月より食事療法中'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.medical_information),
                      title: Text('腰椎ヘルニア'),
                      subtitle: Text('2019年手術実施'),
                    ),
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
                      onPressed: _summarizeIllness,
                      child: const Text('要約する'),
                    ),
                    if (_summarizedIllness.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '要約:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_summarizedIllness),
                    ],
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
                    ),
                    const SizedBox(height: 16),
                    // 検索結果のサンプル
                    const ListTile(
                      leading: Icon(Icons.article),
                      title: Text('血液検査結果 2024/12/25'),
                      subtitle: Text('WBC: 6500, RBC: 450万, PLT: 25万'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.medication),
                      title: Text('処方箋 2024/12/20'),
                      subtitle: Text('アムロジピン(5mg) 1日1回 朝食後'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.event_note),
                      title: Text('診察記録 2024/12/18'),
                      subtitle: Text('血圧安定。服薬継続の方針。'),
                    ),
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
