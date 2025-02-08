import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentPatient extends _$CurrentPatient {
  @override
  Map<String, dynamic>? build() {
    return null;
  }

  void setPatient(Map<String, dynamic> patient) {
    state = patient;
  }

  void clearPatient() {
    state = null;
  }
}
