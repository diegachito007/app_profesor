import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/materia_model.dart';
import '../../../data/models/materia_tipo_model.dart';
import '../../../data/services/materias_tipo_service.dart';
import '../../../shared/utils/notificaciones.dart';
import '../../../data/providers/database_provider.dart';
import '../../../data/providers/materias_por_tipo_provider.dart';
import '../../../data/controllers/materias_controller.dart';
import '../../../shared/utils/texto_normalizado.dart';

final tiposMateriaProvider = FutureProvider<List<MateriaTipo>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final service = MateriasTipoService(db);
  return service.obtenerTipos();
});

class MateriasPage extends ConsumerStatefulWidget {
  const MateriasPage({super.key});

  @override
  ConsumerState<MateriasPage> createState() => _MateriasPageState();
}

class _MateriasPageState extends ConsumerState<MateriasPage> {
  String _filtroTexto = '';
  bool _mostrarBuscador = false;
  int? _tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final tipos = await ref.read(tiposMateriaProvider.future);
      if (tipos.length >= 2) {
        setState(() => _tipoSeleccionado = tipos[1].id);
        ref.invalidate(materiasPorTipoProvider(tipos[1].id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(tiposMateriaProvider);
    final materiasAsync = ref.watch(
      materiasPorTipoProvider(_tipoSeleccionado ?? 0),
    );

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                materiasAsync.when(
                  data: (materias) => Text(
                    '${materias.length} materias registradas',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  loading: () => const Text('Cargando...'),
                  error: (_, __) => const Text('Error al cargar materias'),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.black54),
                      tooltip: 'Mostrar buscador',
                      onPressed: () =>
                          setState(() => _mostrarBuscador = !_mostrarBuscador),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF1565C0),
                        size: 28,
                      ),
                      tooltip: 'Agregar materia',
                      onPressed: () {
                        if (_tipoSeleccionado != null) {
                          _mostrarDialogoMateria(
                            context: context,
                            ref: ref,
                            tipoIdPreseleccionado: _tipoSeleccionado!,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_mostrarBuscador)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar materia...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filtroTexto.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _filtroTexto = ''),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => _filtroTexto = value.trim()),
                ),
              ),
            ),
          tiposAsync.when(
            data: (tipos) => Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: tipos.map((tipo) {
                  final selected = _tipoSeleccionado == tipo.id;
                  return ChoiceChip(
                    label: Text(tipo.sigla),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _tipoSeleccionado = tipo.id);
                      ref.invalidate(materiasPorTipoProvider(tipo.id));
                    },
                  );
                }).toList(),
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Text('Error al cargar tipos: $e'),
          ),
          Expanded(
            child: materiasAsync.when(
              data: (materias) {
                final tipos = ref.watch(tiposMateriaProvider).value ?? [];
                final filtradas = materias
                    .where(
                      (m) => normalizar(
                        m.nombre,
                      ).contains(normalizar(_filtroTexto)),
                    )
                    .toList();

                final agrupadas = <int, List<Materia>>{};
                for (final materia in filtradas) {
                  agrupadas.putIfAbsent(materia.tipoId, () => []).add(materia);
                }

                if (filtradas.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron materias.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: agrupadas.keys.length,
                  itemBuilder: (_, index) {
                    final tipoId = agrupadas.keys.elementAt(index);
                    final tipo = tipos.firstWhere((t) => t.id == tipoId);
                    final grupo = agrupadas[tipoId]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            tipo.nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        ...grupo.map((materia) => _buildCardMateria(materia)),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error al cargar materias: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMateria(Materia materia) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(capitalizarTituloConTildes(materia.nombre))),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _mostrarMenuMateria(context, ref, materia),
          ),
        ],
      ),
    );
  }

  void _mostrarMenuMateria(
    BuildContext context,
    WidgetRef ref,
    Materia materia,
  ) {
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
              leading: const Icon(Icons.edit, color: Colors.blueGrey),
              title: const Text('Editar materia'),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoMateria(
                  context: context,
                  ref: ref,
                  materia: materia,
                  tipoIdPreseleccionado: materia.tipoId,
                );
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
                final confirmado = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Eliminar materia'),
                    content: Text(
                      '¿Estás seguro de eliminar la materia ${materia.nombre}?\n\n'
                      'También se eliminarán todos los datos asociados, como estudiantes, calificaciones y asistencia.\n\n'
                      'Esta acción es permanente y no se puede deshacer.',
                      style: const TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
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
                );

                if (!context.mounted || confirmado != true) return;

                final exito = await ref
                    .read(materiasControllerProvider.notifier)
                    .eliminarMateria(materia.id);

                if (!context.mounted) return;

                if (exito) {
                  Notificaciones.showSuccess(context, 'Materia eliminada');
                  ref.invalidate(materiasPorTipoProvider(materia.tipoId));
                  setState(() => _filtroTexto = '');
                } else {
                  Notificaciones.showError(
                    context,
                    'No se puede eliminar: la materia tiene datos relacionados.',
                  );
                }
              },
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
    required int tipoIdPreseleccionado,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _FormularioMateria(
          materia: materia,
          tipoIdPreseleccionado: tipoIdPreseleccionado,
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

            ref.invalidate(materiasPorTipoProvider(tipoIdPreseleccionado));
            setState(() => _filtroTexto = '');

            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _FormularioMateria extends ConsumerStatefulWidget {
  final Materia? materia;
  final int tipoIdPreseleccionado;
  final void Function(Materia materia) onGuardar;

  const _FormularioMateria({
    required this.materia,
    required this.tipoIdPreseleccionado,
    required this.onGuardar,
  });

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
    final tiposAsync = ref.watch(tiposMateriaProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.materia != null ? 'Editar materia' : 'Nueva materia',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  tiposAsync.when(
                    data: (tipos) {
                      final tipo = tipos.firstWhere(
                        (t) => t.id == widget.tipoIdPreseleccionado,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nivel',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              tipo.nombre,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error al cargar tipos: $e'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la materia',
                      hintText: 'Ej. QUÍMICA AVANZADA',
                      border: OutlineInputBorder(),
                    ),
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
                      child: Text(
                        _errorLogico!,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        child: Text(
                          widget.materia != null ? 'Actualizar' : 'Guardar',
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final nombreRaw = _nombreCtrl.text.trim();
                            final nombreMayus = nombreRaw.toUpperCase();
                            final nombreNormalizado = normalizar(nombreMayus);

                            final materias = await ref.read(
                              materiasControllerProvider.future,
                            );

                            final existe = materias.any(
                              (m) =>
                                  m.id != widget.materia?.id &&
                                  normalizar(m.nombre) == nombreNormalizado,
                            );

                            if (existe) {
                              setState(() {
                                _errorLogico =
                                    'Ya existe una materia con ese nombre';
                              });
                              return;
                            }

                            final nuevaMateria = Materia(
                              id: widget.materia?.id ?? 0,
                              nombre: nombreMayus,
                              tipoId: widget.tipoIdPreseleccionado,
                            );

                            widget.onGuardar(nuevaMateria);
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
