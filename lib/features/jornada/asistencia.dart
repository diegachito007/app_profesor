import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/estudiante_model.dart';
import '../../data/services/estudiantes_service.dart';
import '../../data/providers/database_provider.dart';

class AsistenciaSection extends ConsumerWidget {
  final int cursoId;
  final int materiaCursoId;
  final int hora;

  const AsistenciaSection({
    super.key,
    required this.cursoId,
    required this.materiaCursoId,
    required this.hora,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estudiantesAsync = ref.watch(_estudiantesProvider(cursoId));

    return estudiantesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (estudiantes) {
        if (estudiantes.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'No hay estudiantes asignados a este curso.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puedes agregarlos desde el módulo de estudiantes.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar estudiante'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/estudiantes', // Asegúrate de tener esta ruta definida
                      arguments: cursoId,
                    );
                  },
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: estudiantes.length,
          itemBuilder: (_, i) {
            final est = estudiantes[i];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text('${est.apellido} ${est.nombre}'),
              subtitle: Text('ID: ${est.id} · Cédula: ${est.cedula}'),
            );
          },
        );
      },
    );
  }
}

final _estudiantesProvider = FutureProvider.family<List<Estudiante>, int>((
  ref,
  cursoId,
) async {
  final db = await ref.watch(databaseProvider.future);
  final service = EstudiantesService(db);
  final estudiantes = await service.obtenerPorCurso(cursoId);
  return estudiantes;
});
