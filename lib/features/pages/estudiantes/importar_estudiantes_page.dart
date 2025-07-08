import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/curso_model.dart';
import '../../../data/models/estudiante_model.dart';
import '../../../data/controllers/estudiantes_controller.dart';

class ImportarEstudiantesPage extends ConsumerWidget {
  final Curso curso;

  const ImportarEstudiantesPage({super.key, required this.curso});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar estudiantes')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Compartir plantilla'),
              onPressed: () => _generarYCompartirPlantilla(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Cargar estudiantes'),
              onPressed: () => _cargarArchivo(context, ref, curso.id),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Exportar estudiantes'),
              onPressed: () => _exportarEstudiantes(context, ref, curso.id),
            ),
          ],
        ),
      ),
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

  Future<void> _generarYCompartirPlantilla(BuildContext context) async {
    final excel = Excel.createExcel();
    final sheet = excel['Estudiantes'];
    sheet.appendRow(['CÉDULA', 'NOMBRES', 'APELLIDOS', 'TELÉFONO']);

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/plantilla_estudiantes.xlsx';
    final bytes = excel.encode();
    if (bytes == null) return;

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (!context.mounted) return;
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Aquí tienes la plantilla para importar estudiantes.');
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
    final excel = Excel.decodeBytes(bytes);

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
                            'Cédula: ${est.cedula}  •  Tel: ${est.telefono}',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se importaron $importados estudiantes.')),
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

    final excel = Excel.createExcel();
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
}
