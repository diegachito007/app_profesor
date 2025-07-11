import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/controllers/cursos_controller.dart';
import '../../../data/models/curso_model.dart';
import '../../../data/providers/periodo_activo_provider.dart';

class AgregarCursosPage extends ConsumerStatefulWidget {
  const AgregarCursosPage({super.key});

  @override
  ConsumerState<AgregarCursosPage> createState() => _AgregarCursosPageState();
}

class _AgregarCursosPageState extends ConsumerState<AgregarCursosPage> {
  String? nivelSeleccionado;
  final Set<String> paralelosSeleccionados = {};
  bool _loading = false;

  final Map<String, List<String>> nivelesAgrupados = {
    'INICIAL': ['Inicial 1', 'Inicial 2'],
    'EGB': [
      'Primero EGB',
      'Segundo EGB',
      'Tercero EGB',
      'Cuarto EGB',
      'Quinto EGB',
      'Sexto EGB',
      'Séptimo EGB',
      'Octavo EGB',
      'Noveno EGB',
      'Décimo EGB',
    ],
    'BGU': ['Primero BGU', 'Segundo BGU', 'Tercero BGU'],
  };

  final List<String> paralelos = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  Future<void> guardarCursos() async {
    final periodo = ref.read(periodoActivoProvider);

    if (nivelSeleccionado == null ||
        paralelosSeleccionados.isEmpty ||
        periodo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un nivel y al menos un paralelo'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final controller = ref.read(cursosControllerProvider.notifier);
    final cursosExistentes = await controller.obtenerCursosPorPeriodo(
      periodo.id,
    );

    final nuevosCursos = <Curso>[];

    for (final p in paralelosSeleccionados) {
      final yaExiste = cursosExistentes.any(
        (c) =>
            c.nombre.trim().toLowerCase() ==
                nivelSeleccionado!.trim().toLowerCase() &&
            c.paralelo.toLowerCase() == p.toLowerCase(),
      );

      if (yaExiste) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'El curso "${nivelSeleccionado!} $p" ya está registrado',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        continue;
      }

      nuevosCursos.add(
        Curso(
          id: 0,
          nombre: nivelSeleccionado!, // ✅ solo el grado
          paralelo: p, // ✅ paralelo separado
          periodoId: periodo.id,
          activo: true,
        ),
      );
    }

    if (nuevosCursos.isEmpty) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    await controller.agregarCursos(nuevosCursos);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Cursos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...nivelesAgrupados.entries.map((grupo) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grupo.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: grupo.value.map((nivel) {
                      final seleccionado = nivel == nivelSeleccionado;
                      return ChoiceChip(
                        label: Text(nivel),
                        selected: seleccionado,
                        onSelected: (_) {
                          setState(() {
                            nivelSeleccionado = nivel;
                            paralelosSeleccionados.clear();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'Selecciona los paralelos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: paralelos.map((p) {
                final seleccionado = paralelosSeleccionados.contains(p);
                return FilterChip(
                  label: Text(p),
                  selected: seleccionado,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        paralelosSeleccionados.add(p);
                      } else {
                        paralelosSeleccionados.remove(p);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar Cursos'),
                onPressed: _loading ? null : guardarCursos,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
