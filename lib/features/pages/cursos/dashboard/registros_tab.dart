import 'package:flutter/material.dart';

class RegistroTab extends StatelessWidget {
  final int cursoId;

  const RegistroTab({super.key, required this.cursoId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Aquí se mostrará el registro del curso.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Curso ID: $cursoId',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
