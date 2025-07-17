import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/controllers/materias_curso_controller.dart';
import '../../../../data/controllers/materias_controller.dart';
import '../../../../shared/utils/notificaciones.dart';
import '../../materias_curso/agregar_materias_curso_page.dart';

class MateriasTab extends ConsumerWidget {
  final int cursoId;

  const MateriasTab({super.key, required this.cursoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materiasCursoAsync = ref.watch(
      materiasCursoControllerProvider(cursoId),
    );
    final materiasCatalogo = ref.watch(materiasControllerProvider).value ?? [];
    final materiaMap = {for (var m in materiasCatalogo) m.id: m.nombre};

    return materiasCursoAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar materias: $e')),
      data: (materiasCurso) {
        final activas = materiasCurso.where((mc) => mc.activo).toList();
        final archivadas = materiasCurso.where((mc) => !mc.activo).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔹 Encabezado siempre visible
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${activas.length} activas · ${archivadas.length} archivadas',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF1565C0)),
                  tooltip: 'Agregar materia',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AgregarMateriasCursoPage(cursoId: cursoId),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Estado vacío centrado
            if (materiasCurso.isEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.book_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No hay materias asignadas.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Puedes agregar materias a este curso usando el botón superior.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 🔹 Lista de materias activas
            if (materiasCurso.isNotEmpty) ...[
              ...activas.map((mc) {
                final nombre =
                    materiaMap[mc.materiaId] ?? 'Materia desconocida';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.archive_outlined,
                          color: Colors.blueGrey,
                        ),
                        tooltip: 'Archivar',
                        onPressed: () => _archivarMateria(context, ref, mc),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Eliminar',
                        onPressed: () =>
                            _confirmarEliminar(context, ref, mc, nombre),
                      ),
                    ],
                  ),
                );
              }),

              // 🔹 Lista de materias archivadas
              if (archivadas.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Archivadas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...archivadas.map((mc) {
                  final nombre =
                      materiaMap[mc.materiaId] ?? 'Materia desconocida';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.restore,
                            color: Colors.black45,
                          ),
                          tooltip: 'Restaurar',
                          onPressed: () => _restaurarMateria(context, ref, mc),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ],
        );
      },
    );
  }

  void _archivarMateria(
    BuildContext context,
    WidgetRef ref,
    materiaCurso,
  ) async {
    final controller = ref.read(
      materiasCursoControllerProvider(cursoId).notifier,
    );
    await controller.desactivar(materiaCurso.id, cursoId);
    ref.invalidate(materiasCursoControllerProvider(cursoId));
    if (context.mounted) {
      Notificaciones.showSuccess(context, 'Materia archivada');
    }
  }

  void _restaurarMateria(
    BuildContext context,
    WidgetRef ref,
    materiaCurso,
  ) async {
    final controller = ref.read(
      materiasCursoControllerProvider(cursoId).notifier,
    );
    await controller.restaurar(materiaCurso.id, cursoId);
    ref.invalidate(materiasCursoControllerProvider(cursoId));
    if (context.mounted) {
      Notificaciones.showSuccess(context, 'Materia restaurada');
    }
  }

  void _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    materiaCurso,
    String nombre,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar materia?'),
        content: Text('¿Deseas eliminar la materia "$nombre" del curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final controller = ref.read(
        materiasCursoControllerProvider(cursoId).notifier,
      );
      await controller.eliminar(materiaCurso.id, cursoId);
      ref.invalidate(materiasCursoControllerProvider(cursoId));
      if (context.mounted) {
        Notificaciones.showSuccess(context, 'Materia eliminada');
      }
    }
  }
}
