import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/controllers/materias_curso_controller.dart';
import '../../../data/models/materia_model.dart';
import '../../../data/services/cursos_service.dart';
import '../../../data/services/materias_service.dart';
import '../../../data/services/materias_tipo_service.dart';
import '../../../data/providers/database_provider.dart';
import '../../../shared/utils/notificaciones.dart';

class AgregarMateriasCursoPage extends ConsumerStatefulWidget {
  final int cursoId;

  const AgregarMateriasCursoPage({super.key, required this.cursoId});

  @override
  ConsumerState<AgregarMateriasCursoPage> createState() =>
      _AgregarMateriasCursoPageState();
}

class _AgregarMateriasCursoPageState
    extends ConsumerState<AgregarMateriasCursoPage> {
  final Set<int> _seleccionadas = {};
  late Future<List<Materia>> _materiasFiltradas;
  String _filtro = '';
  bool _mostrarBuscador = false;

  @override
  void initState() {
    super.initState();
    _materiasFiltradas = _filtrarMateriasPorCurso(widget.cursoId);
  }

  Future<List<Materia>> _filtrarMateriasPorCurso(int cursoId) async {
    final db = await ref.read(databaseProvider.future);
    final cursoService = CursosService(db);
    final tipoService = MateriasTipoService(db);
    final materiaService = MateriasService(db);

    final curso = await cursoService.obtenerPorId(cursoId);
    if (curso == null) return [];

    final sigla = _mapearSiglaDesdeCurso(curso.nombre);
    final tipo = await tipoService.obtenerPorSigla(sigla);
    if (tipo == null) return [];

    return await materiaService.obtenerPorTipoId(tipo.id);
  }

  String _mapearSiglaDesdeCurso(String nombreCurso) {
    final nombre = nombreCurso.toLowerCase();

    if (nombre.contains('inicial') || nombre.contains('preparatoria')) {
      return 'I';
    } else if (nombre.contains('bgu') || nombre.contains('egb')) {
      return 'EGB-BGU';
    } else if (nombre.contains('bt')) {
      return 'BT';
    } else if (nombre.contains('bi')) {
      return 'BI';
    }

    return 'EGB-BGU'; // por defecto
  }

  @override
  Widget build(BuildContext context) {
    final asignadasAsync = ref.watch(
      materiasCursoControllerProvider(widget.cursoId),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1565C0),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Asignar materias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<List<Materia>>(
          future: _materiasFiltradas,
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final todasMaterias = snapshot.data!;
            return asignadasAsync.when(
              data: (asignadas) {
                final idsAsignadas = asignadas
                    .map((mc) => mc.materiaId)
                    .toSet();
                final disponibles = todasMaterias
                    .where((m) => !idsAsignadas.contains(m.id))
                    .toList();

                final filtradas = disponibles
                    .where(
                      (m) => m.nombre.toLowerCase().contains(
                        _filtro.toLowerCase(),
                      ),
                    )
                    .toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${disponibles.length} disponibles',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.black54,
                            ),
                            tooltip: 'Buscar materia',
                            onPressed: () => setState(
                              () => _mostrarBuscador = !_mostrarBuscador,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_mostrarBuscador)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar materia...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _filtro.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () =>
                                          setState(() => _filtro = ''),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => _filtro = value),
                          ),
                        ),
                      ),
                    if (filtradas.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('Todas las materias ya están asignadas.'),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtradas.length,
                          itemBuilder: (_, i) {
                            final materia = filtradas[i];
                            final seleccionada = _seleccionadas.contains(
                              materia.id,
                            );

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (seleccionada) {
                                    _seleccionadas.remove(materia.id);
                                  } else {
                                    _seleccionadas.add(materia.id);
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: seleccionada
                                        ? Colors.green.shade300
                                        : Colors.blue.shade100,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        materia.nombre,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: seleccionada
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              key: ValueKey('check'),
                                            )
                                          : const Icon(
                                              Icons.radio_button_unchecked,
                                              color: Colors.black26,
                                              key: ValueKey('empty'),
                                            ),
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
              error: (e, _) =>
                  Center(child: Text('Error al cargar asignaciones: $e')),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: Text(
              _seleccionadas.isEmpty
                  ? 'Asignar materias'
                  : 'Asignar (${_seleccionadas.length}) seleccionadas',
            ),
            onPressed: _seleccionadas.isEmpty
                ? null
                : () async {
                    final controller = ref.read(
                      materiasCursoControllerProvider(widget.cursoId).notifier,
                    );

                    for (final id in _seleccionadas) {
                      await controller.asignar(widget.cursoId, id);
                    }

                    if (context.mounted) {
                      Notificaciones.showSuccess(
                        context,
                        'Materias asignadas correctamente',
                      );
                      Navigator.pop(context);
                    }
                  },
          ),
        ),
      ),
    );
  }
}
