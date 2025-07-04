import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/curso_model.dart';
import '../../data/models/periodo_model.dart';
import '../../data/controllers/cursos_controller.dart';
import '../../data/controllers/materias_curso_controller.dart';
import '../../data/controllers/materias_controller.dart';
import '../../data/providers/periodo_activo_provider.dart';
import '../../data/models/materia_curso_model.dart';
import '../../shared/utils/notificaciones.dart';
import 'agregar_materias_curso_page.dart';

class MateriasCursoPage extends ConsumerWidget {
  const MateriasCursoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodoActivo = ref.watch(periodoActivoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis materias')),
      body: periodoActivo == null
          ? const Center(child: Text('No hay periodo activo.'))
          : _buildContenido(context, ref, periodoActivo),
    );
  }

  Widget _buildContenido(BuildContext context, WidgetRef ref, Periodo periodo) {
    final cursosAsync = ref.watch(cursosControllerProvider);

    return cursosAsync.when(
      data: (cursos) {
        final activos = cursos
            .where((c) => c.activo && c.periodoId == periodo.id)
            .toList();

        if (activos.isEmpty) {
          return const Center(
            child: Text('No hay cursos activos en este periodo.'),
          );
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.grey.shade100,
              child: Text(
                'Periodo: ${periodo.nombre}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activos.length,
                itemBuilder: (context, index) =>
                    _buildCursoCard(context, ref, activos[index], index),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar cursos: $e')),
    );
  }

  Widget _buildCursoCard(
    BuildContext context,
    WidgetRef ref,
    Curso curso,
    int index,
  ) {
    final materiasCursoAsync = ref.watch(
      materiasCursoControllerProvider(curso.id),
    );
    final materiasCatalogo = ref.watch(materiasControllerProvider).value ?? [];

    final materiaMap = {for (var m in materiasCatalogo) m.id: m.nombre};

    final cardColors = [
      Colors.teal.shade50,
      Colors.indigo.shade50,
      Colors.orange.shade50,
      Colors.green.shade50,
      Colors.purple.shade50,
      Colors.pink.shade50,
      Colors.cyan.shade50,
    ];
    final backgroundColor = cardColors[index % cardColors.length];

    return Card(
      elevation: 6,
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: materiasCursoAsync.when(
          data: (materiasCurso) {
            final activas = materiasCurso
                .where((mc) => mc.activo == true)
                .toList();
            final archivadas = materiasCurso
                .where((mc) => mc.activo == false)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      curso.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Asignar materias a este curso',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AgregarMateriasCursoPage(cursoId: curso.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (materiasCurso.isEmpty)
                  const Text('No hay materias asignadas.')
                else ...[
                  if (activas.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activas.map((mc) {
                        final nombre =
                            materiaMap[mc.materiaId] ?? 'Materia desconocida';
                        return Chip(
                          label: Text(nombre),
                          backgroundColor: Colors.blue.shade100,
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () =>
                              _confirmarDesactivacion(context, ref, mc),
                        );
                      }).toList(),
                    ),
                  if (archivadas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Archivadas:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: archivadas.map((mc) {
                        final nombre =
                            materiaMap[mc.materiaId] ?? 'Materia desconocida';
                        return Chip(
                          label: Text(
                            nombre,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          backgroundColor: Colors.grey.shade300,
                          deleteIcon: const Icon(Icons.restore),
                          onDeleted: () => _restaurarMateria(context, ref, mc),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error al cargar materias: $e'),
        ),
      ),
    );
  }

  void _confirmarDesactivacion(
    BuildContext context,
    WidgetRef ref,
    MateriaCurso materiaCurso,
  ) async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Qué deseas hacer con esta materia?'),
        content: const Text(
          'Puedes archivarla para conservar el historial o eliminarla completamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancelar'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'eliminar'),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'archivar'),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );

    final controller = ref.read(
      materiasCursoControllerProvider(materiaCurso.cursoId).notifier,
    );

    if (resultado == 'archivar') {
      await controller.desactivar(materiaCurso.id, materiaCurso.cursoId);
      ref.invalidate(materiasCursoControllerProvider(materiaCurso.cursoId));

      if (context.mounted) {
        Notificaciones.showSuccess(context, 'Materia archivada del curso');
      }
    } else if (resultado == 'eliminar') {
      await controller.eliminar(materiaCurso.id, materiaCurso.cursoId);
      ref.invalidate(materiasCursoControllerProvider(materiaCurso.cursoId));
      if (context.mounted) {
        Notificaciones.showSuccess(context, 'Materia eliminada del curso');
      }
    }
  }

  void _restaurarMateria(
    BuildContext context,
    WidgetRef ref,
    MateriaCurso mc,
  ) async {
    final controller = ref.read(
      materiasCursoControllerProvider(mc.cursoId).notifier,
    );
    await controller.restaurar(mc.id, mc.cursoId);
    ref.invalidate(materiasCursoControllerProvider(mc.cursoId));
    if (context.mounted) {
      Notificaciones.showSuccess(context, 'Materia restaurada');
    }
  }
}
