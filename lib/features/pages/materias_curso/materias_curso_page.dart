import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/curso_model.dart';
import '../../../data/models/periodo_model.dart';
import '../../../data/controllers/cursos_controller.dart';
import '../../../data/controllers/materias_curso_controller.dart';
import '../../../data/controllers/materias_controller.dart';
import '../../../data/providers/periodo_activo_provider.dart';
import '../../../data/models/materia_curso_model.dart';
import '../../../shared/utils/notificaciones.dart';
import 'agregar_materias_curso_page.dart';

final materiasExpandidaProvider = StateProvider<Set<int>>((ref) => {});

class MateriasCursoPage extends ConsumerWidget {
  const MateriasCursoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodoActivo = ref.watch(periodoActivoProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Materias',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: periodoActivo == null
          ? _buildSinPeriodo(context)
          : _buildContenido(context, ref, periodoActivo),
    );
  }

  Widget _buildSinPeriodo(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No hay período activo.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para asignar materias, primero debes activar un período académico.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/periodos'),
              icon: const Icon(Icons.add),
              label: const Text('Crear período'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido(BuildContext context, WidgetRef ref, Periodo periodo) {
    final cursosAsync = ref.watch(cursosControllerProvider);

    return cursosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar cursos: $e')),
      data: (cursos) {
        final activos = cursos
            .where((c) => c.activo && c.periodoId == periodo.id)
            .toList();

        if (activos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'No hay cursos registrados.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para asignar materias, primero debes registrar al menos un curso.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/cursos'),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar curso'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activos.length,
          itemBuilder: (context, index) => Column(
            children: [
              _buildCursoCard(context, ref, activos[index], index),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
    final expandida = ref.watch(materiasExpandidaProvider);

    final chipColors = [
      Colors.teal.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.green.shade100,
      Colors.pink.shade100,
      Colors.indigo.shade100,
      Colors.cyan.shade100,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: materiasCursoAsync.when(
        data: (materiasCurso) {
          final activas = materiasCurso.where((mc) => mc.activo).toList();
          final archivadas = materiasCurso.where((mc) => !mc.activo).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  curso.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${activas.length} activas · ${archivadas.length} archivadas',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              if (materiasCurso.isEmpty)
                const Text('No hay materias asignadas.')
              else ...[
                if (activas.isNotEmpty)
                  Column(
                    children: List.generate(activas.length, (i) {
                      final mc = activas[i];
                      final nombre =
                          materiaMap[mc.materiaId] ?? 'Materia desconocida';
                      final color = chipColors[i % chipColors.length];
                      final isExpanded = expandida.contains(mc.id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: color),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nombre,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    final set = {...expandida};
                                    if (isExpanded) {
                                      set.remove(mc.id);
                                    } else {
                                      set.add(mc.id);
                                    }
                                    ref
                                            .read(
                                              materiasExpandidaProvider
                                                  .notifier,
                                            )
                                            .state =
                                        set;
                                  },
                                  child: const Icon(
                                    Icons.more_vert,
                                    size: 16,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 4),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        _archivarMateria(context, ref, mc),
                                    child: const Text('Archivar'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () =>
                                        _eliminarMateria(context, ref, mc),
                                    child: const Text('Eliminar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final set = {...expandida}..remove(mc.id);
                                      ref
                                              .read(
                                                materiasExpandidaProvider
                                                    .notifier,
                                              )
                                              .state =
                                          set;
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                if (archivadas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Archivadas:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    children: archivadas.map((mc) {
                      final nombre =
                          materiaMap[mc.materiaId] ?? 'Materia desconocida';
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.restore,
                                size: 18,
                                color: Colors.black45,
                              ),
                              tooltip: 'Restaurar materia',
                              onPressed: () =>
                                  _restaurarMateria(context, ref, mc),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AgregarMateriasCursoPage(cursoId: curso.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar materia'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error al cargar materias: $e'),
      ),
    );
  }

  void _archivarMateria(
    BuildContext context,
    WidgetRef ref,
    MateriaCurso mc,
  ) async {
    final controller = ref.read(
      materiasCursoControllerProvider(mc.cursoId).notifier,
    );
    await controller.desactivar(mc.id, mc.cursoId);
    ref.invalidate(materiasCursoControllerProvider(mc.cursoId));
    ref
        .read(materiasExpandidaProvider.notifier)
        .update((s) => s..remove(mc.id));
    if (context.mounted) {
      Notificaciones.showSuccess(context, 'Materia archivada del curso');
    }
  }

  void _eliminarMateria(
    BuildContext context,
    WidgetRef ref,
    MateriaCurso mc,
  ) async {
    final controller = ref.read(
      materiasCursoControllerProvider(mc.cursoId).notifier,
    );
    await controller.eliminar(mc.id, mc.cursoId);
    ref.invalidate(materiasCursoControllerProvider(mc.cursoId));
    ref
        .read(materiasExpandidaProvider.notifier)
        .update((s) => s..remove(mc.id));
    if (context.mounted) {
      Notificaciones.showSuccess(context, 'Materia eliminada del curso');
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
