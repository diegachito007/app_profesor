import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/curso_model.dart';
import '../../../data/controllers/cursos_controller.dart';
import '../../../data/controllers/estudiantes_controller.dart';
import '../../../data/providers/periodo_activo_provider.dart';
import 'agregar_estudiantes_page.dart';

class EstudiantesPage extends ConsumerWidget {
  const EstudiantesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoActivoProvider);
    final cursosAsync = ref.watch(cursosControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes')),
      body: periodo == null
          ? _buildSinPeriodo(context)
          : cursosAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (cursos) {
                final activos = cursos
                    .where((c) => c.activo && c.periodoId == periodo.id)
                    .toList();

                if (activos.isEmpty) {
                  return const Center(
                    child: Text('No hay cursos activos en este período.'),
                  );
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOut,
                  child: ListView.builder(
                    key: ValueKey(activos.length),
                    padding: const EdgeInsets.all(16),
                    itemCount: activos.length,
                    itemBuilder: (context, index) {
                      final curso = activos[index];
                      return _buildCursoCard(context, ref, curso, index);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSinPeriodo(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No hay período activo.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/periodos');
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear período'),
          ),
        ],
      ),
    );
  }

  Widget _buildCursoCard(
    BuildContext context,
    WidgetRef ref,
    Curso curso,
    int index,
  ) {
    final estudiantesAsync = ref.watch(estudiantesControllerProvider(curso.id));

    final cardColors = [
      Colors.teal.shade50,
      Colors.indigo.shade50,
      Colors.orange.shade50,
      Colors.green.shade50,
      Colors.purple.shade50,
      Colors.pink.shade50,
      Colors.cyan.shade50,
    ];
    final backgroundColor = cardColors[index % cardColors.length];

    return Card(
      elevation: 6,
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: estudiantesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error al cargar estudiantes: $e'),
          data: (estudiantes) {
            final total = estudiantes.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        curso.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1),
                      tooltip: 'Agregar o gestionar estudiantes',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AgregarEstudiantesPage(curso: curso),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgregarEstudiantesPage(curso: curso),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Chip(
                    label: Text('$total estudiante${total == 1 ? '' : 's'}'),
                    avatar: const Icon(Icons.group, size: 18),
                    backgroundColor: Colors.blue.shade100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
