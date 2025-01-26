import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';

class PatientSelectionScreen extends StatelessWidget {
  const PatientSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Selection'),
      ),
      body: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text('Patient ${index + 1}'),
              subtitle: Text('Room ${100 + index}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailScreen(
                      patientId: index + 1,
                      patientName: 'Patient ${index + 1}',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
