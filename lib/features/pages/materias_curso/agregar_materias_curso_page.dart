import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/controllers/materias_controller.dart';
import '../../../data/controllers/materias_curso_controller.dart';
import '../../../shared/utils/notificaciones.dart';

class AgregarMateriasCursoPage extends ConsumerStatefulWidget {
  final int cursoId;

  const AgregarMateriasCursoPage({super.key, required this.cursoId});

  @override
  ConsumerState<AgregarMateriasCursoPage> createState() =>
      _AgregarMateriasCursoPageState();
}

class _AgregarMateriasCursoPageState
    extends ConsumerState<AgregarMateriasCursoPage> {
  final Set<int> _seleccionadas = {};

  @override
  Widget build(BuildContext context) {
    final materiasAsync = ref.watch(materiasControllerProvider);
    final asignadasAsync = ref.watch(
      materiasCursoControllerProvider(widget.cursoId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar materias')),
      body: materiasAsync.when(
        data: (todasMaterias) {
          return asignadasAsync.when(
            data: (asignadas) {
              // ✅ Excluir materias activas y archivadas (activo != null)
              final idsAsignadas = asignadas.map((mc) => mc.materiaId).toSet();

              final disponibles = todasMaterias
                  .where((m) => !idsAsignadas.contains(m.id))
                  .toList();

              if (disponibles.isEmpty) {
                return const Center(
                  child: Text('Todas las materias ya están asignadas.'),
                );
              }

              return ListView.builder(
                itemCount: disponibles.length,
                itemBuilder: (_, i) {
                  final materia = disponibles[i];
                  final seleccionada = _seleccionadas.contains(materia.id);

                  return CheckboxListTile(
                    title: Text(materia.nombre),
                    value: seleccionada,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _seleccionadas.add(materia.id);
                        } else {
                          _seleccionadas.remove(materia.id);
                        }
                      });
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Error al cargar asignaciones: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar materias: $e')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Asignar seleccionadas'),
          onPressed: _seleccionadas.isEmpty
              ? null
              : () async {
                  final controller = ref.read(
                    materiasCursoControllerProvider(widget.cursoId).notifier,
                  );

                  for (final id in _seleccionadas) {
                    await controller.asignar(widget.cursoId, id);
                  }

                  if (context.mounted) {
                    Notificaciones.showSuccess(
                      context,
                      'Materias asignadas correctamente',
                    );
                    Navigator.pop(context);
                  }
                },
        ),
      ),
    );
  }
}
