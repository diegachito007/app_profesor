import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/materia_curso_model.dart';
import '../../../data/controllers/horarios_controller.dart';
import '../../../data/providers/materias_curso_global_provider.dart';

class EditarHorariosPage extends ConsumerStatefulWidget {
  final String dia;
  final int hora;
  final MateriaCurso? seleccionada;

  const EditarHorariosPage({
    super.key,
    required this.dia,
    required this.hora,
    this.seleccionada,
  });

  @override
  ConsumerState<EditarHorariosPage> createState() => _EditarHorarioPageState();
}

class _EditarHorarioPageState extends ConsumerState<EditarHorariosPage> {
  @override
  Widget build(BuildContext context) {
    final materiasAsync = ref.watch(materiasCursoGlobalProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar bloque horario')),
      body: materiasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (materias) {
          final activas = materias.where((m) => m.activo).toList();

          if (activas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No hay materias activas en ningún curso.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Día: ${widget.dia} — Hora: ${widget.hora}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: activas.length,
                  itemBuilder: (context, index) {
                    final mc = activas[index];
                    final nombreMateria = mc.nombreMateria ?? 'Materia';
                    final nombreCurso = mc.nombreCursoCompleto;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          await ref
                              .read(
                                horariosControllerProvider(widget.dia).notifier,
                              )
                              .guardarBloque(
                                dia: widget.dia,
                                hora: widget.hora,
                                materiaCursoId: mc.id,
                              );

                          if (!mounted) return;

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Asignado: $nombreMateria en $nombreCurso',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          navigator.pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreCurso,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                nombreMateria,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
