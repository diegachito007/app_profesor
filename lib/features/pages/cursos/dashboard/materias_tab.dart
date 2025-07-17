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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${activas.length} activas · ${archivadas.length} archivadas',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF1565C0),
                    ),
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
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),
                  if (materiasCurso.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No hay materias asignadas.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Puedes agregar materias a este curso usando el botón superior.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (materiasCurso.isNotEmpty) ...[
                    ...activas.map((mc) {
                      final nombre =
                          materiaMap[mc.materiaId] ?? 'Materia desconocida';
                      return _buildMateriaCard(context, ref, mc, nombre, true);
                    }),
                    ...archivadas.map((mc) {
                      final nombre =
                          materiaMap[mc.materiaId] ?? 'Materia desconocida';
                      return _buildMateriaCard(context, ref, mc, nombre, false);
                    }),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMateriaCard(
    BuildContext context,
    WidgetRef ref,
    dynamic mc,
    String nombre,
    bool activa,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: activa ? Colors.blue.shade100 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                fontSize: activa ? 15 : 14,
                fontWeight: activa ? FontWeight.w500 : FontWeight.normal,
                fontStyle: activa ? FontStyle.normal : FontStyle.italic,
                color: activa ? Colors.black87 : Colors.black54,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _mostrarMenuMateria(context, ref, mc, nombre),
          ),
        ],
      ),
    );
  }

  void _mostrarMenuMateria(
    BuildContext context,
    WidgetRef ref,
    dynamic mc,
    String nombre,
  ) {
    final controller = ref.read(
      materiasCursoControllerProvider(cursoId).notifier,
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mc.activo)
              ListTile(
                leading: const Icon(
                  Icons.archive_outlined,
                  color: Colors.blueGrey,
                ),
                title: const Text('Archivar materia'),
                onTap: () async {
                  Navigator.pop(context);
                  await controller.desactivar(mc.id, cursoId);
                  ref.invalidate(materiasCursoControllerProvider(cursoId));
                  if (!context.mounted) return;
                  Notificaciones.showSuccess(context, 'Materia archivada');
                },
              ),
            if (!mc.activo)
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.black45),
                title: const Text('Restaurar materia'),
                onTap: () async {
                  Navigator.pop(context);
                  await controller.restaurar(mc.id, cursoId);
                  ref.invalidate(materiasCursoControllerProvider(cursoId));
                  if (!context.mounted) return;
                  Notificaciones.showSuccess(context, 'Materia restaurada');
                },
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text('Eliminar materia'),
              onTap: () async {
                Navigator.pop(context);
                final confirmado =
                    await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Eliminar materia'),
                        content: Text(
                          '¿Estás seguro de eliminar la materia $nombre del curso?\n\n'
                          'Esta acción es permanente y no se puede deshacer.',
                          style: const TextStyle(fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (!context.mounted || !confirmado) return;

                await controller.eliminar(mc.id, cursoId);
                ref.invalidate(materiasCursoControllerProvider(cursoId));
                if (context.mounted) {
                  Notificaciones.showSuccess(context, 'Materia eliminada');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
