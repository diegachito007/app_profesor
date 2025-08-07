import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/controllers/cursos_controller.dart';
import '../../../data/models/periodo_model.dart';
import '../../../data/models/curso_model.dart';
import '../../../data/providers/periodo_activo_provider.dart';
import '../../../shared/utils/notificaciones.dart';
import '../../../shared/utils/colores.dart';

import 'agregar_cursos_page.dart';

class CursosPage extends ConsumerStatefulWidget {
  const CursosPage({super.key});

  @override
  ConsumerState<CursosPage> createState() => _CursosPageState();
}

class _CursosPageState extends ConsumerState<CursosPage> {
  bool _mostrarArchivados = false;

  @override
  void initState() {
    super.initState();
    ref.listen<Periodo?>(periodoActivoProvider, (previous, next) {
      if (mounted) setState(() {});
    });
  }

  String pluralizar(int cantidad, String singular, String plural) {
    return '$cantidad ${cantidad == 1 ? singular : plural}';
  }

  @override
  Widget build(BuildContext context) {
    final cursosAsync = ref.watch(cursosControllerProvider);
    final periodoActivo = ref.watch(periodoActivoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cursos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cursosAsync.when(
        data: (cursos) {
          final activas = cursos.where((c) => c.activo).toList();
          final archivadas = cursos.where((c) => !c.activo).toList();
          final cursosOrdenados = [
            ...activas,
            if (_mostrarArchivados) ...archivadas,
          ];

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${pluralizar(activas.length, "activo", "activos")} · ${pluralizar(archivadas.length, "archivado", "archivados")}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (archivadas.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  _mostrarArchivados
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                  color: Colors.black45,
                                ),
                                tooltip: _mostrarArchivados
                                    ? 'Ocultar archivados'
                                    : 'Mostrar archivados',
                                onPressed: () => setState(() {
                                  _mostrarArchivados = !_mostrarArchivados;
                                }),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF1565C0),
                            size: 28,
                          ),
                          tooltip: 'Agregar curso',
                          onPressed: periodoActivo == null
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AgregarCursosPage(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (cursos.isNotEmpty)
                      const Text(
                        'Toca un curso para gestionar sus materias y estudiantes.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: cursos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              periodoActivo == null
                                  ? Icons.calendar_today
                                  : Icons.event_note,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              periodoActivo == null
                                  ? 'No hay período activo.'
                                  : 'No hay cursos registrados.',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            if (periodoActivo == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Para registrar cursos, primero debes activar un período académico.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (periodoActivo == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/periodos'),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear período'),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          ...cursosOrdenados.map(
                            (curso) => _buildCursoCard(context, ref, curso),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Ocurrió un error al cargar los cursos.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Intenta nuevamente o revisa tu conexión.',
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: () => ref.invalidate(cursosControllerProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCursoCard(BuildContext context, WidgetRef ref, Curso curso) {
    colorPorCurso(curso.nombreCompleto);
    final fondoSuave = colorSuavizadoPorCurso(curso.nombreCompleto);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: fondoSuave,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          curso.nombreCompleto,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: curso.activo ? Colors.indigo : Colors.grey,
            fontStyle: curso.activo ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _mostrarMenuCurso(context, ref, curso),
        ),
        onTap: () {
          if (!curso.activo) {
            Notificaciones.showWarning(context, 'Este curso está archivado.');
            return;
          }
          Navigator.pushNamed(context, '/dashboard-curso', arguments: curso);
        },
      ),
    );
  }

  void _mostrarMenuCurso(BuildContext context, WidgetRef ref, Curso curso) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                curso.activo ? Icons.archive_outlined : Icons.restore,
                color: Colors.grey.shade700,
              ),
              title: Text(curso.activo ? 'Archivar curso' : 'Restaurar curso'),
              onTap: () async {
                Navigator.pop(context);

                if (curso.activo) {
                  await ref
                      .read(cursosControllerProvider.notifier)
                      .archivarCurso(curso.id);
                } else {
                  await ref
                      .read(cursosControllerProvider.notifier)
                      .restaurarCurso(curso.id);
                }

                if (!context.mounted) return;

                Notificaciones.showSuccess(
                  context,
                  curso.activo ? 'Curso archivado' : 'Curso restaurado',
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text('Eliminar curso'),
              onTap: () async {
                Navigator.pop(context);
                final confirmado =
                    await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Eliminar curso'),
                        content: Text(
                          '¿Estás seguro de eliminar el curso ${curso.nombreCompleto}?\n\n'
                          'También se eliminarán todos los datos asociados, como materias, estudiantes y calificaciones.\n\n'
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

                final exito = await ref
                    .read(cursosControllerProvider.notifier)
                    .eliminarCurso(curso.id);

                if (!context.mounted) return;

                if (exito) {
                  Notificaciones.showSuccess(context, 'Curso eliminado');
                } else {
                  Notificaciones.showError(
                    context,
                    'No se puede eliminar: el curso tiene datos relacionados.',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
