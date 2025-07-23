import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/controllers/horarios_controller.dart';
import '../../../data/models/horario_expandido.dart';
import '../../../data/models/horario_model.dart';
import '../../../routes/app_routes.dart';

class HorariosPage extends ConsumerWidget {
  const HorariosPage({super.key});

  final List<String> dias = const [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
  ];
  final List<int> horas = const [1, 2, 3, 4, 5, 6, 7];

  Color generarColor(String curso, String materia) {
    final base = '$curso-$materia';
    final hash = base.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b).withAlpha(40);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: dias.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1565C0),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Mi horario',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: const Color(0xFF1565C0),
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black45,
                tabs: dias.map((dia) => Tab(text: dia)).toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: dias
              .map((dia) => _buildDiaView(context, ref, dia))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDiaView(BuildContext context, WidgetRef ref, String dia) {
    final horariosAsync = ref.watch(horariosControllerProvider(dia));

    return horariosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (horarios) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: horas.length,
          itemBuilder: (context, index) {
            final hora = horas[index];
            final bloque = horarios.firstWhere(
              (h) => h.horario.hora == hora,
              orElse: () => HorarioExpandido(
                horario: Horario(
                  id: 0,
                  dia: dia,
                  hora: hora,
                  materiaCursoId: 0,
                ),
                materiaCurso: null,
                nombreCurso: '',
                nombreMateria: '',
              ),
            );

            final estaVacio = bloque.horario.id == 0;
            final esActivo = bloque.estaActivo;

            final cardColor = estaVacio
                ? Colors.grey.shade200
                : esActivo
                ? generarColor(
                    bloque.nombreCursoFinal,
                    bloque.nombreMateriaFinal,
                  )
                : Colors.orange.shade100;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    hora.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                title: estaVacio
                    ? const Text(
                        'Bloque sin asignar',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bloque.nombreCursoFinal,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: esActivo ? Colors.indigo : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bloque.nombreMateriaFinal,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: esActivo ? Colors.black87 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                trailing: estaVacio
                    ? IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: "Asignar bloque",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.editarHorario,
                            arguments: {
                              'dia': dia,
                              'hora': hora,
                              'horario': null,
                            },
                          );
                        },
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        tooltip: "Eliminar bloque",
                        onPressed: () async {
                          final confirmar =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.redAccent,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '¿Eliminar bloque?',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Esta acción eliminará el bloque asignado a la hora $hora del $dia.\n\nNo se eliminarán las materias ni cursos, solo la asignación en el horario.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;

                          if (confirmar) {
                            final controller = ref.read(
                              horariosControllerProvider(dia).notifier,
                            );
                            await controller.eliminarHorario(
                              bloque.horario.id!,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bloque eliminado')),
                            );
                          }
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
