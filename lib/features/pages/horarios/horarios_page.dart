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
    return Color.fromARGB(255, r, g, b).withAlpha(60); // ✅ más suave
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: dias.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mi horario"),
          bottom: TabBar(tabs: dias.map((dia) => Tab(text: dia)).toList()),
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
          padding: const EdgeInsets.all(16),
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
            final cardColor = estaVacio
                ? Colors
                      .grey
                      .shade200 // ✅ fondo para bloques vacíos
                : generarColor(bloque.nombreCurso, bloque.nombreMateria);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
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
                    ? null
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bloque.nombreCurso,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bloque.nombreMateria,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                subtitle: const SizedBox.shrink(),
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
                        icon: const Icon(Icons.delete, size: 20),
                        tooltip: "Eliminar bloque",
                        onPressed: () {
                          ref
                              .read(horariosControllerProvider(dia).notifier)
                              .eliminarHorario(bloque.horario.id!);
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
