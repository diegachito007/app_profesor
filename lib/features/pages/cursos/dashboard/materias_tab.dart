import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/controllers/materias_curso_controller.dart';
import '../../../../data/controllers/materias_controller.dart';
import '../../../../shared/utils/notificaciones.dart';
import '../../materias_curso/agregar_materias_curso_page.dart';
import '../../../../shared/utils/texto_normalizado.dart';
import '../../../../shared/utils/colores.dart';

final mostrarArchivadasProvider = StateProvider<bool>((ref) => false);

class MateriasTab extends ConsumerWidget {
  final int cursoId;
  final String nombreCurso;

  const MateriasTab({
    super.key,
    required this.cursoId,
    required this.nombreCurso,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materiasCursoAsync = ref.watch(
      materiasCursoControllerProvider(cursoId),
    );
    final materiasCatalogo = ref.watch(materiasControllerProvider).value ?? [];
    final materiaMap = {for (var m in materiasCatalogo) m.id: m.nombre};
    final mostrarArchivadas = ref.watch(mostrarArchivadasProvider);

    return materiasCursoAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar materias: $e')),
      data: (materiasCurso) {
        final activas = materiasCurso
            .where((mc) => mc.activo && materiaMap.containsKey(mc.materiaId))
            .toList();

        final archivadas = materiasCurso
            .where((mc) => !mc.activo && materiaMap.containsKey(mc.materiaId))
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${activas.length} ${activas.length == 1 ? "activa" : "activas"} · '
                      '${archivadas.length} ${archivadas.length == 1 ? "archivada" : "archivadas"}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    if (archivadas.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          mostrarArchivadas
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        tooltip: mostrarArchivadas
                            ? 'Ocultar archivadas'
                            : 'Mostrar archivadas',
                        onPressed: () {
                          ref.read(mostrarArchivadasProvider.notifier).state =
                              !mostrarArchivadas;
                        },
                      ),
                  ],
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

            if (activas.isEmpty && archivadas.isEmpty)
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

            if (activas.isNotEmpty || archivadas.isNotEmpty) ...[
              ...activas.map((mc) {
                final nombre = materiaMap[mc.materiaId]!;
                return _buildMateriaCard(context, ref, mc, nombre, true);
              }),
              if (mostrarArchivadas)
                ...archivadas.map((mc) {
                  final nombre = materiaMap[mc.materiaId]!;
                  return _buildMateriaCard(context, ref, mc, nombre, false);
                }),
            ],
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
    final esArchivada = !activa;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorSuavizadoPorMateria(
          nombreCurso,
          factor: activa ? 0.08 : 0.04,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (esArchivada)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.archive_outlined, size: 18, color: Colors.grey),
            ),
          Expanded(
            child: Text(
              capitalizarTituloConTildes(nombre),
              style: TextStyle(
                fontSize: 13, // 👈 Letra más pequeña para nombres largos
                color: esArchivada ? Colors.black54 : Colors.black87,
                fontStyle: esArchivada ? FontStyle.italic : FontStyle.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
