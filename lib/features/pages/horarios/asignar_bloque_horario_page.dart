import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/materia_curso_model.dart';
import '../../../data/controllers/horarios_controller.dart';
import '../../../data/providers/materias_curso_global_provider.dart';
import '../../../shared/utils/texto_normalizado.dart';

class AsignarBloqueHorarioPage extends ConsumerStatefulWidget {
  final String dia;
  final int hora;
  final MateriaCurso? seleccionada;

  const AsignarBloqueHorarioPage({
    super.key,
    required this.dia,
    required this.hora,
    this.seleccionada,
  });

  @override
  ConsumerState<AsignarBloqueHorarioPage> createState() =>
      _AsignarBloqueHorarioPageState();
}

class _AsignarBloqueHorarioPageState
    extends ConsumerState<AsignarBloqueHorarioPage> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(materiasCursoGlobalProvider, (_, __) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final materiasAsync = ref.watch(materiasCursoGlobalProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Asignar bloque horario',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: materiasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (materias) {
          final activas = materias.where((m) => m.activo).toList();

          if (activas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'No hay materias activas en ningún curso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        color: Colors.blue[600],
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Día: ${widget.dia}  •  Hora: ${widget.hora}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: activas.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemBuilder: (context, index) {
                    final mc = activas[index];
                    final nombreMateria = capitalizarTituloConTildes(
                      mc.nombreMateria ?? 'Materia',
                    );
                    final nombreCurso = capitalizarTituloConTildes(
                      mc.nombreCursoCompleto,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.shade100),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreCurso,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
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
