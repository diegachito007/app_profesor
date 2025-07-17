import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/estudiante_model.dart';
import '../../../../data/controllers/estudiantes_controller.dart';

class EstudiantesTab extends ConsumerStatefulWidget {
  final int cursoId;

  const EstudiantesTab({super.key, required this.cursoId});

  @override
  ConsumerState<EstudiantesTab> createState() => _EstudiantesTabState();
}

class _EstudiantesTabState extends ConsumerState<EstudiantesTab> {
  String _filtro = '';
  bool _mostrarBuscador = false;

  String capitalizar(String texto) {
    return texto
        .toLowerCase()
        .split(' ')
        .map(
          (p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final estudiantesAsync = ref.watch(
      estudiantesControllerProvider(widget.cursoId),
    );

    return estudiantesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (estudiantes) {
        final filtrados =
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${estudiantes.length} estudiante${estudiantes.length == 1 ? '' : 's'} asignado${estudiantes.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _mostrarBuscador ? Icons.close : Icons.search,
                          color: Colors.black54,
                        ),
                        tooltip: 'Buscar estudiante',
                        onPressed: () => setState(
                          () => _mostrarBuscador = !_mostrarBuscador,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'Opciones',
                        onPressed: () => _mostrarMenu(context),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.person_add,
                          color: Color(0xFF1565C0),
                        ),
                        tooltip: 'Agregar estudiante',
                        onPressed: () => _mostrarFormulario(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_mostrarBuscador) ...[
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar estudiante...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => setState(() => _filtro = value),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (filtrados.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No hay estudiantes asignados.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Puedes agregar estudiantes usando el botón superior.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (filtrados.isNotEmpty)
                    ...filtrados.map(
                      (est) => _buildCardEstudiante(context, est),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardEstudiante(BuildContext context, Estudiante est) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0F0FF), width: 1.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(
              10,
              0,
              0,
              0,
            ), // reemplazo de withOpacity(0.04)
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${capitalizar(est.apellido)} ${capitalizar(est.nombre)}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
            tooltip: 'Ver información',
            onPressed: () => _mostrarDialogoEstudiante(context, est),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEstudiante(BuildContext context, Estudiante est) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${est.apellido} ${est.nombre}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.badge, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text('Cédula: ${est.cedula}'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.phone, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _llamar(est.telefono),
                  child: Text(
                    est.telefono,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarFormulario(context, est);
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarEstudiante(context, est);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMenu(BuildContext context) {
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
              leading: const Icon(Icons.share),
              title: const Text('Descargar plantilla'),
              onTap: () {
                Navigator.pop(context);
                _generarYCompartirPlantilla(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Importar estudiantes'),
              onTap: () {
                Navigator.pop(context);
                _cargarArchivo(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exportar estudiantes'),
              onTap: () {
                Navigator.pop(context);
                _exportarEstudiantes(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
              ),
              title: const Text('Eliminar todos'),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacionMasiva(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cargarArchivo(BuildContext context) async {
    const typeGroup = XTypeGroup(label: 'Excel', extensions: ['xlsx']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final excel = xls.Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null || sheet.maxCols < 4) {
      if (!context.mounted) return;
      _mostrarAlerta(context, 'El archivo no tiene el formato requerido.');
      return;
    }

    final headers = sheet.rows.first
        .map((e) => e?.value?.toString().trim().toUpperCase())
        .toList();
    const esperado = ['CÉDULA', 'NOMBRES', 'APELLIDOS', 'TELÉFONO'];

    final formatoValido = List.generate(
      4,
      (i) => headers[i] == esperado[i],
    ).every((e) => e);
    if (!formatoValido) {
      if (!context.mounted) return;
      _mostrarAlerta(
        context,
        'Las columnas deben ser: CÉDULA, NOMBRES, APELLIDOS, TELÉFONO.',
      );
      return;
    }

    final List<Estudiante> estudiantes = [];
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.length < 4) continue;

      final cedula = row[0]?.value?.toString().trim() ?? '';
      final nombres = _normalizarTexto(row[1]?.value?.toString().trim() ?? '');
      final apellidos = _normalizarTexto(
        row[2]?.value?.toString().trim() ?? '',
      );
      var telefono = row[3]?.value?.toString().trim() ?? '';
      telefono = telefono.replaceAll(RegExp(r'\D'), '');
      if (telefono.length == 9) telefono = '0$telefono';

      if (cedula.length != 10 ||
          nombres.isEmpty ||
          apellidos.isEmpty ||
          telefono.length != 10) {
        continue;
      }

      estudiantes.add(
        Estudiante(
          id: 0,
          cedula: cedula,
          nombre: nombres,
          apellido: apellidos,
          telefono: telefono,
          cursoId: widget.cursoId,
        ),
      );
    }

    if (estudiantes.isEmpty) {
      if (!context.mounted) return;
      _mostrarAlerta(context, 'No se encontraron estudiantes válidos.');
      return;
    }

    if (!context.mounted) return;

    final confirmar =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Confirmar importación'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Se encontraron los siguientes estudiantes:'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: estudiantes.length,
                      itemBuilder: (_, index) {
                        final est = estudiantes[index];
                        return ListTile(
                          dense: true,
                          title: Text('${est.apellido} ${est.nombre}'),
                          subtitle: Text(
                            'Cédula: ${est.cedula}\nTeléfono: ${est.telefono}',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Importar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!context.mounted || !confirmar) return;

    final controller = ref.read(
      estudiantesControllerProvider(widget.cursoId).notifier,
    );
    int importados = 0;

    for (final est in estudiantes) {
      final existe = await controller.existeCedula(est.cedula);
      if (!existe) {
        await controller.agregarEstudiante(est);
        importados++;
      }
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Importación exitosa!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Se importaron $importados estudiantes correctamente.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportarEstudiantes(BuildContext context) async {
    final estudiantes =
        ref.read(estudiantesControllerProvider(widget.cursoId)).value ?? [];
    if (estudiantes.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay estudiantes para exportar.')),
      );
      return;
    }

    final excel = xls.Excel.createExcel();
    final sheet = excel['Estudiantes'];
    sheet.appendRow(['CÉDULA', 'NOMBRES', 'APELLIDOS', 'TELÉFONO']);

    for (final est in estudiantes) {
      sheet.appendRow([est.cedula, est.nombre, est.apellido, est.telefono]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/estudiantes_exportados.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    if (!context.mounted) return;
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Listado de estudiantes exportado.');
  }

  Future<void> _confirmarEliminacionMasiva(BuildContext context) async {
    final confirmar =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¿Eliminar todos los estudiantes?'),
            content: const Text(
              'Esta acción eliminará todos los estudiantes del curso. ¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar todos'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar || !context.mounted) return;

    final controller = ref.read(
      estudiantesControllerProvider(widget.cursoId).notifier,
    );
    await controller.eliminarTodosLosEstudiantes();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Limpieza completada!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Todos los estudiantes fueron eliminados del curso.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generarYCompartirPlantilla(BuildContext context) async {
    final excel = xls.Excel.createExcel();
    final sheet = excel['Estudiantes'];
    sheet.appendRow(['CÉDULA', 'NOMBRES', 'APELLIDOS', 'TELÉFONO']);

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/plantilla_estudiantes.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    if (!context.mounted) return;
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Aquí tienes la plantilla para importar estudiantes.');
  }

  Future<void> _llamar(String numero) async {
    final uri = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _mostrarFormulario(BuildContext context, [Estudiante? estudiante]) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _FormularioEstudiante(
          cursoId: widget.cursoId,
          estudiante: estudiante,
        ),
      ),
    );
  }

  Future<void> _eliminarEstudiante(BuildContext context, Estudiante est) async {
    final confirmar =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¿Eliminar estudiante?'),
            content: Text('¿Deseas eliminar a "${est.nombreCompleto}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmar) {
      final controller = ref.read(
        estudiantesControllerProvider(widget.cursoId).notifier,
      );
      await controller.eliminarEstudiante(est.id, widget.cursoId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Estudiante eliminado')));
    }
  }

  void _mostrarAlerta(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atención'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String _normalizarTexto(String input) {
    const tildes = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ñ': 'Ñ',
      'Ñ': 'Ñ',
    };
    var texto = input;
    tildes.forEach((original, reemplazo) {
      texto = texto.replaceAll(original, reemplazo);
    });
    return texto.toUpperCase();
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
  String? _errorLogico;

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
                ],
              ),
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
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _errorLogico =
                                'Ya existe un estudiante con esa cédula';
                          });
                          return;
                        }

                        await controller.agregarEstudiante(estudiante);
                        if (!context.mounted) return;
                        setState(() => _errorLogico = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Estudiante guardado')),
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
    );
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
