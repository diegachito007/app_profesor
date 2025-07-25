import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/cursos_controller.dart';
import '../../data/models/periodo_model.dart';
import '../../data/models/curso_model.dart';
import '../../data/providers/periodo_activo_provider.dart';
import '../../shared/utils/showdialogs.dart';
import '../../shared/utils/notificaciones.dart';

import 'agregar_cursos_page.dart';

class CursosPage extends ConsumerStatefulWidget {
  const CursosPage({super.key});

  @override
  ConsumerState<CursosPage> createState() => _CursosPageState();
}

class _CursosPageState extends ConsumerState<CursosPage> {
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    ref.listen<Periodo?>(periodoActivoProvider, (previous, next) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final cursosAsync = ref.watch(cursosControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cursos')),
      body: cursosAsync.when(
        data: (cursos) {
          final cursosFiltrados = cursos
              .where(
                (c) => c.nombreCompleto.toLowerCase().contains(
                  _filtro.toLowerCase(),
                ),
              )
              .toList();

          final activos = cursosFiltrados.where((c) => c.activo).toList();
          final archivados = cursosFiltrados.where((c) => !c.activo).toList();

          if (cursos.isEmpty) {
            return const Center(child: Text('No hay cursos registrados.'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar curso...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _filtro = value),
                ),
              ),
              if (activos.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Cursos activos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ...activos.map((curso) => _buildCursoTile(context, ref, curso)),
              ],
              if (archivados.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Cursos archivados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ...archivados.map(
                  (curso) => _buildCursoTile(context, ref, curso),
                ),
              ],
              if (activos.isEmpty && archivados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No se encontraron cursos.')),
                ),
              const SizedBox(height: 100),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
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
              Text(
                e.toString(),
                style: const TextStyle(color: Colors.black54),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Acción de exportar
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Exportar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgregarCursosPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCursoTile(BuildContext context, WidgetRef ref, Curso curso) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                curso.nombreCompleto,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: curso.activo ? Colors.black87 : Colors.grey,
                  fontStyle: curso.activo ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                curso.activo
                    ? Icons.archive_outlined
                    : Icons.unarchive_outlined,
                color: curso.activo ? Colors.blueGrey : Colors.green,
              ),
              tooltip: curso.activo ? 'Archivar' : 'Restaurar',
              onPressed: () async {
                final confirmado = await ShowDialogs.showArchiveConfirmation(
                  context: context,
                  entityName: 'curso',
                  itemLabel: curso.nombreCompleto,
                  archivar: curso.activo,
                );
                if (confirmado == true) {
                  await ref
                      .read(cursosControllerProvider.notifier)
                      .archivarCurso(curso.id);
                  if (context.mounted) {
                    Notificaciones.showSuccess(
                      context,
                      curso.activo ? 'Curso archivado' : 'Curso restaurado',
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: 'Eliminar curso',
              onPressed: () async {
                final confirmado = await ShowDialogs.showDeleteConfirmation(
                  context: context,
                  entityName: 'curso',
                  itemLabel: curso.nombreCompleto,
                );
                if (confirmado == true) {
                  final exito = await ref
                      .read(cursosControllerProvider.notifier)
                      .eliminarCurso(curso.id);
                  if (context.mounted) {
                    if (exito) {
                      Notificaciones.showSuccess(context, 'Curso eliminado');
                    } else {
                      Notificaciones.showError(
                        context,
                        'No se puede eliminar: el curso tiene datos relacionados.',
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
