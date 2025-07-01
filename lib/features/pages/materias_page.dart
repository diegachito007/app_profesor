import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/materias_controller.dart';
import '../../data/models/materia_model.dart';
import '../../shared/utils/log_helper.dart'; // ✅ Importación añadida

final filtroMateriasProvider = StateProvider<String>((ref) => '');

class MateriasPage extends ConsumerWidget {
  const MateriasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroMateriasProvider);
    final materiasAsync = ref.watch(materiasControllerProvider);

    final materiasFiltradasAsync = materiasAsync.whenData((materias) {
      if (filtro.isEmpty) return materias;
      return materias
          .where((m) => m.nombre.toLowerCase().contains(filtro.toLowerCase()))
          .toList();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: materiasFiltradasAsync.when(
        data: (materias) {
          if (materias.isEmpty) {
            return const Center(child: Text('No hay materias registradas.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar materia...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: filtro.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                ref
                                        .read(filtroMateriasProvider.notifier)
                                        .state =
                                    '',
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) =>
                      ref.read(filtroMateriasProvider.notifier).state = value,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: materias.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (_, i) {
                    final materia = materias[i];
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
                              color: Colors.black.withAlpha(
                                (0.03 * 255).round(),
                              ),
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
                              onPressed: () =>
                                  _mostrarDialogoEditar(context, ref, materia),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Eliminar materia',
                              onPressed: () =>
                                  _confirmarEliminacion(context, ref, materia),
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
                LogHelper.showWarning(
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
              onPressed: () => _mostrarDialogoAgregar(context, ref),
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

  void _mostrarDialogoAgregar(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar materia'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nombre de la materia'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = controller.text.trim();
              Navigator.pop(context);

              if (nombre.length < 3) {
                if (context.mounted) {
                  LogHelper.showWarning(
                    context,
                    'El nombre debe tener al menos 3 caracteres.',
                  );
                }
                return;
              }

              final materias = ref.read(materiasControllerProvider).value ?? [];
              final yaExiste = materias.any(
                (m) => m.nombre.toLowerCase() == nombre.toLowerCase(),
              );

              if (yaExiste) {
                if (context.mounted) {
                  LogHelper.showWarning(
                    context,
                    'La materia "$nombre" ya existe.',
                  );
                }
                return;
              }

              final nueva = Materia(id: 0, nombre: nombre);
              try {
                await ref
                    .read(materiasControllerProvider.notifier)
                    .agregarMateria(nueva);
                if (context.mounted) {
                  LogHelper.showSuccess(context, 'Materia "$nombre" agregada');
                }
              } catch (_) {
                if (context.mounted) {
                  LogHelper.showError(context, 'Error al agregar la materia');
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditar(
    BuildContext context,
    WidgetRef ref,
    Materia materia,
  ) {
    final controller = TextEditingController(text: materia.nombre);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar materia'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nuevo nombre'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoNombre = controller.text.trim();
              Navigator.pop(context);

              if (nuevoNombre.length < 3) {
                if (context.mounted) {
                  LogHelper.showWarning(
                    context,
                    'El nombre debe tener al menos 3 caracteres.',
                  );
                }
                return;
              }

              if (nuevoNombre == materia.nombre) return;

              final materias = ref.read(materiasControllerProvider).value ?? [];
              final yaExiste = materias.any(
                (m) =>
                    m.id != materia.id &&
                    m.nombre.toLowerCase() == nuevoNombre.toLowerCase(),
              );

              if (yaExiste) {
                if (context.mounted) {
                  LogHelper.showWarning(
                    context,
                    'Ya existe una materia con el nombre "$nuevoNombre".',
                  );
                }
                return;
              }

              final actualizada = Materia(id: materia.id, nombre: nuevoNombre);
              try {
                await ref
                    .read(materiasControllerProvider.notifier)
                    .actualizarMateria(actualizada);
                if (context.mounted) {
                  LogHelper.showSuccess(
                    context,
                    'Materia actualizada a "$nuevoNombre"',
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  LogHelper.showError(
                    context,
                    'Error al actualizar la materia',
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(
    BuildContext context,
    WidgetRef ref,
    Materia materia,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación'),
        content: Text('¿Eliminar la materia "${materia.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(materiasControllerProvider.notifier)
                    .eliminarMateria(materia.id);
                if (context.mounted) {
                  LogHelper.showSuccess(
                    context,
                    'Materia "${materia.nombre}" eliminada',
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  LogHelper.showError(context, 'Error al eliminar la materia');
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
