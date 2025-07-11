import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ],
                              ),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    'Teléfono: ${est.telefono}',
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
                                        onPressed: () => _eliminarEstudiante(
                                          context,
                                          ref,
                                          est,
                                        ),
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
              icon: const Icon(Icons.more_vert),
              label: const Text('Opciones'),
              onPressed: () => _mostrarMenuImportacion(context, ref),
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

  void _mostrarMenuImportacion(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
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
                title: const Text('Cargar estudiantes'),
                onTap: () {
                  Navigator.pop(context);
                  _cargarArchivo(context, ref, widget.curso.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Exportar estudiantes'),
                onTap: () {
                  Navigator.pop(context);
                  _exportarEstudiantes(context, ref, widget.curso.id);
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
                  _confirmarEliminacionMasiva(context, ref, widget.curso.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String normalizarTexto(String input) {
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

  Future<void> _cargarArchivo(
    BuildContext context,
    WidgetRef ref,
    int cursoId,
  ) async {
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
      final nombres = normalizarTexto(row[1]?.value?.toString().trim() ?? '');
      final apellidos = normalizarTexto(row[2]?.value?.toString().trim() ?? '');
      var telefono = row[3]?.value?.toString().trim() ?? '';

      telefono = telefono.replaceAll(RegExp(r'\D'), '');
      if (telefono.length == 9) {
        telefono = '0$telefono';
      }

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
          cursoId: cursoId,
        ),
      );
    }

    if (!context.mounted) return;

    if (estudiantes.isEmpty) {
      _mostrarAlerta(context, 'No se encontraron estudiantes válidos.');
      return;
    }

    final confirmar =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
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
                            style: const TextStyle(height: 1.4),
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
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Importar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar || !context.mounted) return;

    final controller = ref.read(
      estudiantesControllerProvider(cursoId).notifier,
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

  Future<void> _exportarEstudiantes(
    BuildContext context,
    WidgetRef ref,
    int cursoId,
  ) async {
    final estudiantes =
        ref.read(estudiantesControllerProvider(cursoId)).value ?? [];

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
    ], text: 'Aquí tienes el listado de estudiantes exportado.');
  }

  Future<void> _confirmarEliminacionMasiva(
    BuildContext context,
    WidgetRef ref,
    int cursoId,
  ) async {
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
      estudiantesControllerProvider(cursoId).notifier,
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

  Future<void> _eliminarEstudiante(
    BuildContext context,
    WidgetRef ref,
    Estudiante est,
  ) async {
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmar) {
      final controller = ref.read(
        estudiantesControllerProvider(widget.curso.id).notifier,
      );
      await controller.eliminarEstudiante(est.id, widget.curso.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Estudiante eliminado')));
    }
  }

  Future<void> _llamarTelefono(String numero) async {
    final uri = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('No se pudo lanzar el marcador para $numero');
    }
  }

  Future<void> _generarYCompartirPlantilla(BuildContext context) async {
    try {
      final excel = xls.Excel.createExcel();
      final sheet = excel['Estudiantes'];

      // Agregar solo los encabezados
      sheet.appendRow(['CÉDULA', 'NOMBRES', 'APELLIDOS', 'TELÉFONO']);

      // Guardar archivo
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/descargar_plantilla.xlsx';
      final bytes = excel.encode();

      if (bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo generar el archivo Excel'),
            ),
          );
        }
        return;
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo guardar la plantilla')),
          );
        }
        return;
      }

      if (!context.mounted) return;

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Aquí tienes la plantilla para importar estudiantes.');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir la plantilla: $e')),
        );
      }
    }
  }
} // ← Cierre final de la clase _AgregarEstudiantesPageState

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
