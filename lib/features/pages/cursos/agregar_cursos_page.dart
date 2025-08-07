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
  List<String> _erroresDuplicados = [];

  final Map<String, List<String>> nivelesPorTipoMateria = {
    'Educación Inicial y Preparatoria': [
      'Inicial 1',
      'Inicial 2',
      'Preparatoria',
    ],
    'EGB y Bachillerato General': [
      'Segundo EGB',
      'Tercero EGB',
      'Cuarto EGB',
      'Quinto EGB',
      'Sexto EGB',
      'Séptimo EGB',
      'Octavo EGB',
      'Noveno EGB',
      'Décimo EGB',
      'Primero BGU',
      'Segundo BGU',
      'Tercero BGU',
    ],
    'Bachillerato Técnico': ['Primero BT', 'Segundo BT', 'Tercero BT'],
    'Bachillerato Internacional': ['Primero BI', 'Segundo BI', 'Tercero BI'],
  };

  final List<String> paralelos = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  Future<void> guardarCursos() async {
    final periodo = ref.read(periodoActivoProvider);

    if (nivelSeleccionado == null ||
        paralelosSeleccionados.isEmpty ||
        periodo == null) {
      if (!mounted) return;
      setState(() {
        _erroresDuplicados = ['Selecciona un nivel y al menos un paralelo'];
      });
      return;
    }

    setState(() {
      _loading = true;
      _erroresDuplicados.clear();
    });

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
        _erroresDuplicados.add(
          'El curso "$nivelSeleccionado $p" ya está registrado',
        );
        continue;
      }

      nuevosCursos.add(
        Curso(
          id: 0,
          nombre: nivelSeleccionado!,
          paralelo: p,
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

    if (_erroresDuplicados.isEmpty) {
      Navigator.pop(context);
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Agregar Cursos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final alturaTotal = constraints.maxHeight;
          const alturaInferior = 180.0;
          final alturaCard = alturaTotal - alturaInferior - 32;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Desliza para ver otros niveles educativos.',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: alturaCard,
                        child: PageView.builder(
                          itemCount: nivelesPorTipoMateria.length,
                          controller: PageController(viewportFraction: 0.92),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final grupo = nivelesPorTipoMateria.entries
                                .elementAt(index);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.school,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              grupo.key,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: grupo.value.map((nivel) {
                                          final seleccionado =
                                              nivel == nivelSeleccionado;
                                          return ChoiceChip(
                                            label: Text(nivel),
                                            selected: seleccionado,
                                            onSelected: (_) {
                                              setState(() {
                                                nivelSeleccionado = nivel;
                                                paralelosSeleccionados.clear();
                                                _erroresDuplicados.clear();
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_erroresDuplicados.isNotEmpty)
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Conflictos detectados:',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ..._erroresDuplicados.map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                color: Colors.orange,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona los paralelos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: paralelos.map((p) {
                          final seleccionado = paralelosSeleccionados.contains(
                            p,
                          );
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
                                _erroresDuplicados.clear();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
