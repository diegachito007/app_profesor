import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/curso_model.dart';
import '../../../data/models/estudiante_model.dart';
import '../../../data/controllers/estudiantes_controller.dart';

class AgregarEstudiantesPage extends ConsumerStatefulWidget {
  final Curso curso;

  const AgregarEstudiantesPage({super.key, required this.curso});

  @override
  ConsumerState<AgregarEstudiantesPage> createState() =>
      _AgregarEstudiantesPageState();
}

class _AgregarEstudiantesPageState
    extends ConsumerState<AgregarEstudiantesPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  Estudiante? _estudianteEditando;

  void _limpiarCampos() {
    _cedulaCtrl.clear();
    _nombreCtrl.clear();
    _apellidoCtrl.clear();
    _telefonoCtrl.clear();
    _estudianteEditando = null;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _guardarEstudiante() async {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = ref.read(
        estudiantesControllerProvider(widget.curso.id).notifier,
      );

      final estudiante = Estudiante(
        id: _estudianteEditando?.id ?? 0,
        cedula: _cedulaCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        cursoId: widget.curso.id,
      );

      if (_estudianteEditando != null) {
        await controller.actualizarEstudiante(estudiante);
        _mostrarMensaje('Estudiante actualizado');
      } else {
        final existe = await controller.existeCedula(estudiante.cedula);
        if (existe) {
          _mostrarMensaje('Ya existe un estudiante con esa cédula');
          return;
        }
        await controller.agregarEstudiante(estudiante);
        _mostrarMensaje('Estudiante guardado');
      }

      _limpiarCampos();
      setState(() {});
    }
  }

  Future<bool> _confirmarEliminacion(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Eliminar estudiante?'),
            content: Text('¿Estás seguro de eliminar a "$nombre"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final estudiantesAsync = ref.watch(
      estudiantesControllerProvider(widget.curso.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes de ${widget.curso.nombreCompleto}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cedulaCtrl,
                    decoration: const InputDecoration(labelText: 'Cédula'),
                    maxLength: 10,
                    enabled: _estudianteEditando == null,
                    validator: (value) => value == null || value.length != 10
                        ? 'Debe tener 10 dígitos'
                        : null,
                  ),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombres'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo obligatorio'
                        : null,
                  ),
                  TextFormField(
                    controller: _apellidoCtrl,
                    decoration: const InputDecoration(labelText: 'Apellidos'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo obligatorio'
                        : null,
                  ),
                  TextFormField(
                    controller: _telefonoCtrl,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            _estudianteEditando != null
                                ? Icons.update
                                : Icons.save,
                          ),
                          label: Text(
                            _estudianteEditando != null
                                ? 'Actualizar estudiante'
                                : 'Guardar estudiante',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _estudianteEditando != null
                                ? Colors.orange
                                : null,
                          ),
                          onPressed: _guardarEstudiante,
                        ),
                      ),
                      if (_estudianteEditando != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Cancelar edición',
                          onPressed: () {
                            setState(() {
                              _limpiarCampos();
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: estudiantesAsync.when(
                data: (estudiantes) {
                  if (estudiantes.isEmpty) {
                    return const Center(
                      child: Text('No hay estudiantes registrados.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: estudiantes.length,
                    itemBuilder: (_, index) {
                      final est = estudiantes[index];
                      return ListTile(
                        title: Text(est.nombreCompleto),
                        subtitle: Text(est.telefonoFormateado),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _cedulaCtrl.text = est.cedula;
                                  _nombreCtrl.text = est.nombre;
                                  _apellidoCtrl.text = est.apellido;
                                  _telefonoCtrl.text = est.telefono;
                                  _estudianteEditando = est;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirmar = await _confirmarEliminacion(
                                  est.nombreCompleto,
                                );
                                if (!confirmar) return;

                                final controller = ref.read(
                                  estudiantesControllerProvider(
                                    widget.curso.id,
                                  ).notifier,
                                );
                                await controller.eliminarEstudiante(
                                  est.id,
                                  widget.curso.id,
                                );
                                _mostrarMensaje('Estudiante eliminado');
                              },
                            ),
                          ],
                        ),
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
}
