import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/controllers/materias_controller.dart';
import '../../../data/models/materia_model.dart';
import '../../../data/models/materia_tipo_model.dart';
import '../../../data/services/materias_tipo_service.dart';
import '../../../shared/utils/notificaciones.dart';
import '../../../shared/utils/dialogo_confirmacion.dart';
import '../../../data/providers/database_provider.dart';

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
  int? _materiaExpandidaId;
  int? _tipoSeleccionado;

  final Map<String, Color> coloresPorTipo = {
    'I': Colors.lightBlueAccent,
    'EGB-BGU': Colors.greenAccent,
    'BT': Colors.orangeAccent,
    'BI': Colors.purpleAccent,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final tipos = await ref.read(tiposMateriaProvider.future);
      if (tipos.length >= 2) {
        setState(() => _tipoSeleccionado = tipos[1].id);
        ref
            .read(materiasControllerProvider.notifier)
            .cargarPorTipo(tipos[1].id);
      }
    });
  }

  void _cerrarMenuExpandido() {
    if (_materiaExpandidaId != null) {
      setState(() => _materiaExpandidaId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final materiasAsync = ref.watch(materiasControllerProvider);
    final tiposAsync = ref.watch(tiposMateriaProvider);

    return GestureDetector(
      onTap: _cerrarMenuExpandido,
      child: Scaffold(
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    loading: () => const Text('Cargando...'),
                    error: (_, __) => const Text('Error'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black54),
                        tooltip: 'Buscar materia',
                        onPressed: () => setState(
                          () => _mostrarBuscador = !_mostrarBuscador,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF1565C0),
                          size: 28,
                        ),
                        tooltip: 'Agregar materia',
                        onPressed: () =>
                            _mostrarDialogoMateria(context: context, ref: ref),
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
                              onPressed: () =>
                                  setState(() => _filtroTexto = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) => setState(() => _filtroTexto = value),
                  ),
                ),
              ),
            tiposAsync.when(
              data: (tipos) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  children: tipos.map((tipo) {
                    final selected = _tipoSeleccionado == tipo.id;
                    return ChoiceChip(
                      label: Text(tipo.sigla),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _tipoSeleccionado = tipo.id);
                        ref
                            .read(materiasControllerProvider.notifier)
                            .cargarPorTipo(tipo.id);
                      },
                    );
                  }).toList(),
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
            Expanded(
              child: materiasAsync.when(
                data: (materias) {
                  final tipos = ref.watch(tiposMateriaProvider).value ?? [];
                  final filtradas = materias
                      .where(
                        (m) => m.nombre.toLowerCase().contains(
                          _filtroTexto.toLowerCase(),
                        ),
                      )
                      .toList();

                  final agrupadas = <int, List<Materia>>{};
                  for (final materia in filtradas) {
                    agrupadas
                        .putIfAbsent(materia.tipoId, () => [])
                        .add(materia);
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
                      final colorBorde =
                          coloresPorTipo[tipo.sigla] ?? Colors.grey.shade300;

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
                          ...grupo.map(
                            (materia) => AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colorBorde),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(25),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(materia.nombre)),
                                        IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () {
                                            setState(() {
                                              _materiaExpandidaId =
                                                  _materiaExpandidaId ==
                                                      materia.id
                                                  ? null
                                                  : materia.id;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    if (_materiaExpandidaId == materia.id)
                                      Column(
                                        children: [
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(
                                              Icons.edit,
                                              color: Colors.blueGrey,
                                            ),
                                            title: const Text('Editar'),
                                            onTap: () {
                                              _mostrarDialogoMateria(
                                                context: context,
                                                ref: ref,
                                                materia: materia,
                                              );
                                              setState(
                                                () =>
                                                    _materiaExpandidaId = null,
                                              );
                                            },
                                          ),
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                            title: const Text('Eliminar'),
                                            onTap: () => _confirmarEliminacion(
                                              context,
                                              ref,
                                              materia,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
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
  int? _tipoIdSeleccionado;
  String? _errorLogico;

  @override
  void initState() {
    super.initState();
    if (widget.materia != null) {
      _nombreCtrl.text = widget.materia!.nombre;
      _tipoIdSeleccionado = widget.materia!.tipoId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(tiposMateriaProvider);
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
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  tiposAsync.when(
                    data: (tipos) => DropdownButtonFormField<int>(
                      value: _tipoIdSeleccionado,
                      items: tipos.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo.id,
                          child: Text(
                            tipo.sigla,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        _tipoIdSeleccionado = value;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Nivel',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (value) =>
                          value == null ? 'Selecciona un nivel' : null,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error al cargar tipos: $e'),
                  ),
                  const SizedBox(height: 12),
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
                              tipoId: _tipoIdSeleccionado!,
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
