import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    final estudiantesAsync = ref.watch(
      estudiantesControllerProvider(widget.curso.id),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes')),
      body: estudiantesAsync.when(
        data: (estudiantes) {
          final estudiantesFiltrados =
              estudiantes
                  .where(
                    (e) => e.nombreCompleto.toLowerCase().contains(
                      _filtro.toLowerCase(),
                    ),
                  )
                  .toList()
                ..sort((a, b) => a.apellido.compareTo(b.apellido));

          return Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${widget.curso.nombreCompleto} (${estudiantes.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar estudiante...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _filtro = value),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: estudiantesFiltrados.isEmpty
                    ? const Center(
                        child: Text('No se encontraron estudiantes.'),
                      )
                    : ListView.builder(
                        itemCount: estudiantesFiltrados.length,
                        itemBuilder: (_, index) {
                          final est = estudiantesFiltrados[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${est.apellido} ${est.nombre}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cédula: ${est.cedula}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Tooltip(
                                          message: 'Llamar',
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            onTap: () =>
                                                _llamarTelefono(est.telefono),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone,
                                                    size: 16,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      est.telefono,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blueGrey,
                                        ),
                                        tooltip: 'Editar estudiante',
                                        onPressed: () => _mostrarDialogo(
                                          context,
                                          ref,
                                          estudiante: est,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: 'Eliminar estudiante',
                                        onPressed: () async {
                                          final confirmar =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text(
                                                    '¿Eliminar estudiante?',
                                                  ),
                                                  content: Text(
                                                    '¿Deseas eliminar a "${est.nombreCompleto}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Eliminar',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ) ??
                                              false;

                                          if (confirmar) {
                                            final controller = ref.read(
                                              estudiantesControllerProvider(
                                                widget.curso.id,
                                              ).notifier,
                                            );
                                            await controller.eliminarEstudiante(
                                              est.id,
                                              widget.curso.id,
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Estudiante eliminado',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
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
            OutlinedButton.icon(
              icon: const Icon(Icons.table_chart),
              label: const Text('Importar'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/importar_estudiantes',
                  arguments: widget.curso,
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              onPressed: () => _mostrarDialogo(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogo(
    BuildContext context,
    WidgetRef ref, {
    Estudiante? estudiante,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _FormularioEstudiante(
          cursoId: widget.curso.id,
          estudiante: estudiante,
        ),
      ),
    );
  }

  Future<void> _llamarTelefono(String numero) async {
    final uri = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('No se pudo lanzar el marcador para $numero');
    }
  }
}

class UppercaseSinTildesFormatter extends TextInputFormatter {
  static const _tildes = {
    'á': 'A',
    'é': 'E',
    'í': 'I',
    'ó': 'O',
    'ú': 'U',
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'ñ': 'Ñ',
    'Ñ': 'Ñ',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String texto = newValue.text;
    _tildes.forEach((original, reemplazo) {
      texto = texto.replaceAll(original, reemplazo);
    });
    texto = texto.toUpperCase();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _FormularioEstudiante extends ConsumerStatefulWidget {
  final int cursoId;
  final Estudiante? estudiante;

  const _FormularioEstudiante({required this.cursoId, this.estudiante});

  @override
  ConsumerState<_FormularioEstudiante> createState() =>
      _FormularioEstudianteState();
}

class _FormularioEstudianteState extends ConsumerState<_FormularioEstudiante> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.estudiante != null) {
      _cedulaCtrl.text = widget.estudiante!.cedula;
      _nombreCtrl.text = widget.estudiante!.nombre;
      _apellidoCtrl.text = widget.estudiante!.apellido;
      _telefonoCtrl.text = widget.estudiante!.telefono;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(
      estudiantesControllerProvider(widget.cursoId).notifier,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.estudiante != null
                  ? 'Editar estudiante'
                  : 'Nuevo estudiante',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cedulaCtrl,
                    decoration: const InputDecoration(labelText: 'Cédula'),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    enabled: widget.estudiante == null,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) => value == null || value.length != 10
                        ? 'Debe tener 10 dígitos'
                        : null,
                  ),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombres'),
                    inputFormatters: [UppercaseSinTildesFormatter()],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo obligatorio'
                        : null,
                  ),
                  TextFormField(
                    controller: _apellidoCtrl,
                    decoration: const InputDecoration(labelText: 'Apellidos'),
                    inputFormatters: [UppercaseSinTildesFormatter()],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo obligatorio'
                        : null,
                  ),
                  TextFormField(
                    controller: _telefonoCtrl,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) => value == null || value.length != 10
                        ? 'Debe tener 10 dígitos'
                        : null,
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
                          widget.estudiante != null ? 'Actualizar' : 'Guardar',
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final estudiante = Estudiante(
                              id: widget.estudiante?.id ?? 0,
                              cedula: _cedulaCtrl.text.trim(),
                              nombre: _nombreCtrl.text.trim(),
                              apellido: _apellidoCtrl.text.trim(),
                              telefono: _telefonoCtrl.text.trim(),
                              cursoId: widget.cursoId,
                            );

                            if (widget.estudiante != null) {
                              await controller.actualizarEstudiante(estudiante);
                              if (context.mounted) Navigator.pop(context);
                            } else {
                              final existe = await controller.existeCedula(
                                estudiante.cedula,
                              );
                              if (existe) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ya existe un estudiante con esa cédula',
                                    ),
                                  ),
                                );
                                return;
                              }

                              await controller.agregarEstudiante(estudiante);

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Estudiante guardado'),
                                ),
                              );

                              _cedulaCtrl.clear();
                              _nombreCtrl.clear();
                              _apellidoCtrl.clear();
                              _telefonoCtrl.clear();
                              FocusScope.of(context).unfocus();
                            }
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
