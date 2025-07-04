import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/controllers/cursos_controller.dart';
import '../../data/controllers/periodos_controller.dart';
import '../../data/models/periodo_model.dart';
import '../../shared/utils/notificaciones.dart';
import '../../shared/utils/dialogo_confirmacion.dart';
import '../../shared/utils/periodo/dialogo_periodo_form.dart';

class PeriodosPage extends ConsumerStatefulWidget {
  const PeriodosPage({super.key});

  @override
  ConsumerState<PeriodosPage> createState() => _PeriodosPageState();
}

class _PeriodosPageState extends ConsumerState<PeriodosPage> {
  String _filtro = '';

  Future<void> _confirmarEliminacion(Periodo periodo) async {
    final confirmado = await mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Eliminar período',
      mensaje:
          '¿Estás seguro de que deseas eliminar el período "${periodo.nombre}"?',
      textoConfirmar: 'Eliminar',
      colorConfirmar: Colors.redAccent,
      icono: Icons.warning_amber_rounded,
    );

    if (confirmado) {
      try {
        final controller = ref.read(periodosControllerProvider.notifier);
        await controller.eliminarPeriodo(periodo.id);
        if (!mounted) return;
        Notificaciones.showSuccess(context, "Período eliminado correctamente");
      } catch (e) {
        if (!mounted) return;
        Notificaciones.showError(context, "Error al eliminar período: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodosAsync = ref.watch(periodosControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Períodos")),
      body: periodosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (periodos) {
          final controller = ref.read(periodosControllerProvider.notifier);

          if (periodos.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron períodos.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final filtrados = periodos
              .where(
                (p) => p.nombre.toLowerCase().contains(_filtro.toLowerCase()),
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar período...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _filtro = value),
                ),
              ),
              if (filtrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No se encontraron períodos.')),
                ),
              ...filtrados.map((p) => _buildPeriodoTile(p, controller)),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Acción de exportar
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Exportar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () =>
                  mostrarDialogoPeriodoForm(context: context, ref: ref),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodoTile(Periodo periodo, PeriodosController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              periodo.nombre,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text("Inicio: ${DateFormat('dd/MM/yyyy').format(periodo.inicio)}"),
            Text("Fin: ${DateFormat('dd/MM/yyyy').format(periodo.fin)}"),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  periodo.estadoLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: periodo.activo ? Colors.green : Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    if (!periodo.activo)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Activar este período',
                        onPressed: () async {
                          await controller.activarPeriodo(periodo.id);
                          ref.invalidate(cursosControllerProvider);
                        },
                      )
                    else
                      const IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: null,
                        tooltip: 'Período activo',
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      tooltip: 'Editar período',
                      onPressed: () => mostrarDialogoPeriodoForm(
                        context: context,
                        ref: ref,
                        periodo: periodo,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Eliminar período',
                      onPressed: () => _confirmarEliminacion(periodo),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
