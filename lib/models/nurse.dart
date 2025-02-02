class Nurse {
  final String name;
  final String ward;
  final List<String> assignedPatients;

  const Nurse({
    required this.name,
    required this.ward,
    required this.assignedPatients,
  });

  // プリファレンスに保存するためにJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ward': ward,
      'assignedPatients': assignedPatients,
    };
  }

  // JSONからインスタンスを作成
  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      name: json['name'] as String,
      ward: json['ward'] as String,
      assignedPatients: List<String>.from(json['assignedPatients'] as List),
    );
  }
}
