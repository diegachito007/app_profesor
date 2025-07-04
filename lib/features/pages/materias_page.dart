import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/materias_controller.dart';
import '../../data/models/materia_model.dart';
import '../../shared/utils/notificaciones.dart';
import '../../shared/utils/showdialogs.dart';

class MateriasPage extends ConsumerStatefulWidget {
  const MateriasPage({super.key});

  @override
  ConsumerState<MateriasPage> createState() => _MateriasPageState();
}

class _MateriasPageState extends ConsumerState<MateriasPage> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    final materiasAsync = ref.watch(materiasControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: materiasAsync.when(
        data: (materias) {
          final materiasFiltradas = materias
              .where(
                (m) => m.nombre.toLowerCase().contains(_filtro.toLowerCase()),
              )
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar materia...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filtro.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _filtro = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => setState(() => _filtro = value),
                ),
              ),
              if (materiasFiltradas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No se encontraron materias.')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: materiasFiltradas.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (_, i) {
                      final materia = materiasFiltradas[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  materia.nombre,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueGrey,
                                ),
                                tooltip: 'Editar materia',
                                onPressed: () => _mostrarDialogoMateria(
                                  context: context,
                                  ref: ref,
                                  materia: materia,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Eliminar materia',
                                onPressed: () => _confirmarEliminacion(
                                  context,
                                  ref,
                                  materia,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                'Ocurrió un error al cargar las materias.',
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
                onPressed: () => ref.invalidate(materiasControllerProvider),
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
                Notificaciones.showWarning(
                  context,
                  'Función de exportar aún no implementada',
                );
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
              onPressed: () =>
                  _mostrarDialogoMateria(context: context, ref: ref),
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

  void _mostrarDialogoMateria({
    required BuildContext context,
    required WidgetRef ref,
    Materia? materia,
  }) {
    final controller = TextEditingController(text: materia?.nombre ?? '');

    ShowDialogs.showSimpleFormDialog(
      context: context,
      title: materia == null ? 'Agregar materia' : 'Editar materia',
      confirmText: materia == null ? 'Guardar' : 'Actualizar',
      buildContent: (setState) => TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Nombre de la materia',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        autofocus: true,
      ),
      onSubmit: (setError) async {
        final nombre = controller.text.trim();

        if (nombre.length < 3) {
          setError('El nombre debe tener al menos 3 caracteres.');
          return;
        }

        final materias = ref.read(materiasControllerProvider).value ?? [];
        final yaExiste = materias.any(
          (m) =>
              m.nombre.toLowerCase() == nombre.toLowerCase() &&
              m.id != (materia?.id ?? 0),
        );

        if (yaExiste) {
          setError('La materia "$nombre" ya existe.');
          return;
        }

        try {
          if (materia == null) {
            final nueva = Materia(id: 0, nombre: nombre);
            await ref
                .read(materiasControllerProvider.notifier)
                .agregarMateria(nueva);
            if (context.mounted) {
              Notificaciones.showSuccess(context, 'Materia "$nombre" agregada');
            }
          } else {
            final actualizada = Materia(id: materia.id, nombre: nombre);
            await ref
                .read(materiasControllerProvider.notifier)
                .actualizarMateria(actualizada);
            if (context.mounted) {
              Notificaciones.showSuccess(
                context,
                'Materia actualizada a "$nombre"',
              );
            }
          }
        } catch (_) {
          setError('Error al guardar la materia');
        }
      },
    );
  }

  void _confirmarEliminacion(
    BuildContext context,
    WidgetRef ref,
    Materia materia,
  ) async {
    final confirm = await ShowDialogs.showDeleteConfirmation(
      context: context,
      entityName: 'materia',
      itemLabel: materia.nombre,
    );

    if (confirm == true) {
      try {
        await ref
            .read(materiasControllerProvider.notifier)
            .eliminarMateria(materia.id);
        if (context.mounted) {
          Notificaciones.showSuccess(
            context,
            'Materia "${materia.nombre}" eliminada',
          );
        }
      } catch (_) {
        if (context.mounted) {
          Notificaciones.showError(context, 'Error al eliminar la materia');
        }
      }
    }
  }
}
