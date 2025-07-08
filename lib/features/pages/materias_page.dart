import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/controllers/materias_controller.dart';
import '../../data/models/materia_model.dart';
import '../../shared/utils/notificaciones.dart';
import '../../shared/utils/dialogo_confirmacion.dart';

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
          final filtradas = materias
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
                  ),
                  onChanged: (value) => setState(() => _filtro = value),
                ),
              ),
              if (filtradas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No se encontraron materias.')),
                )
              else
                Expanded(
                  // ... (importaciones y clase MateriasPage sin cambios)
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtradas.length,
                    itemBuilder: (_, index) {
                      final materia = filtradas[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
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
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  materia.nombre,
                                  style: const TextStyle(fontSize: 15),
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
        error: (e, _) => Center(child: Text('Error: $e')),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _FormularioMateria(
          materia: materia,
          onGuardar: (materiaActualizada) async {
            final controller = ref.read(materiasControllerProvider.notifier);
            if (materia == null) {
              await controller.agregarMateria(materiaActualizada);
              if (context.mounted) {
                Notificaciones.showSuccess(context, 'Materia guardada');
              }
            } else {
              await controller.actualizarMateria(materiaActualizada);
              if (context.mounted) {
                Notificaciones.showSuccess(context, 'Materia actualizada');
              }
            }
          },
        ),
      ),
    );
  }

  void _confirmarEliminacion(
    BuildContext context,
    WidgetRef ref,
    Materia materia,
  ) async {
    final confirmado = await mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Eliminar materia',
      mensaje: '¿Deseas eliminar la materia "${materia.nombre}"?',
      textoConfirmar: 'Eliminar',
      colorConfirmar: Colors.redAccent,
      icono: Icons.warning_amber_rounded,
    );

    if (confirmado) {
      try {
        await ref
            .read(materiasControllerProvider.notifier)
            .eliminarMateria(materia.id);
        if (context.mounted) {
          Notificaciones.showSuccess(context, 'Materia eliminada');
        }
      } catch (_) {
        if (context.mounted) {
          Notificaciones.showError(context, 'Error al eliminar la materia');
        }
      }
    }
  }
}

class _FormularioMateria extends ConsumerStatefulWidget {
  final Materia? materia;
  final void Function(Materia materia) onGuardar;

  const _FormularioMateria({required this.materia, required this.onGuardar});

  @override
  ConsumerState<_FormularioMateria> createState() => _FormularioMateriaState();
}

class _FormularioMateriaState extends ConsumerState<_FormularioMateria> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  String? _errorLogico;

  @override
  void initState() {
    super.initState();
    if (widget.materia != null) {
      _nombreCtrl.text = widget.materia!.nombre;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(materiasControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.materia != null ? 'Editar materia' : 'Nueva materia',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      if (value.trim().length < 3) {
                        return 'Debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  if (_errorLogico != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        color: Colors.orange.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.orange.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorLogico!,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        child: Text(
                          widget.materia != null ? 'Actualizar' : 'Guardar',
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final nombre = _nombreCtrl.text.trim();
                            final existe = await controller.existeNombreMateria(
                              nombre,
                            );

                            if (existe && widget.materia == null) {
                              setState(() {
                                _errorLogico =
                                    'Ya existe una materia con ese nombre';
                              });
                              return;
                            }

                            final nuevaMateria = Materia(
                              id: widget.materia?.id ?? 0,
                              nombre: nombre,
                            );

                            widget.onGuardar(nuevaMateria);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
