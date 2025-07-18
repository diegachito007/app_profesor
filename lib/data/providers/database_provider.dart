import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = p.join(dir.path, 'profeshor.db');

  final db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await _crearTablas(db);
    },
  );

  return db;
});

Future<void> _crearTablas(Database db) async {
  await db.execute('''
    CREATE TABLE periodos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      fecha_inicio TEXT NOT NULL,
      fecha_fin TEXT NOT NULL,
      activo INTEGER DEFAULT 0
    );
  ''');

  await db.execute('''
    CREATE TABLE cursos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL,
      paralelo TEXT NOT NULL,
      periodo_id INTEGER NOT NULL,
      activo INTEGER DEFAULT 1,
      FOREIGN KEY (periodo_id) REFERENCES periodos(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE tipos_materia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL UNIQUE,
      sigla TEXT NOT NULL UNIQUE
    );
  ''');

  await db.execute('''
    CREATE TABLE materias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL UNIQUE,
      tipo_id INTEGER NOT NULL,
      FOREIGN KEY (tipo_id) REFERENCES tipos_materia(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE materias_curso (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      curso_id INTEGER NOT NULL,
      materia_id INTEGER NOT NULL,
      activo INTEGER DEFAULT 1,
      fecha_asignacion TEXT NOT NULL,
      fecha_desactivacion TEXT,
      FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE,
      FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE estudiantes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cedula TEXT NOT NULL UNIQUE CHECK(length(cedula) <= 10),
      nombre TEXT NOT NULL,
      apellido TEXT NOT NULL,
      curso_id INTEGER NOT NULL,
      telefono TEXT CHECK(length(telefono) >= 10),
      FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE evaluaciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo TEXT NOT NULL,
      descripcion TEXT,
      fecha TEXT NOT NULL,
      materia_curso_id INTEGER NOT NULL,
      ponderacion REAL NOT NULL CHECK(ponderacion BETWEEN 0 AND 100),
      trimestre TEXT NOT NULL CHECK(trimestre IN ('1', '2', '3')),
      FOREIGN KEY (materia_curso_id) REFERENCES materias_curso(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE notas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      estudiante_id INTEGER NOT NULL,
      evaluacion_id INTEGER NOT NULL,
      nota REAL NOT NULL CHECK(nota BETWEEN 0 AND 10),
      estado TEXT CHECK(estado IN ('Regular', 'Recuperado', 'No asistió')),
      fecha_recuperacion TEXT,
      FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
      FOREIGN KEY (evaluacion_id) REFERENCES evaluaciones(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE esquemas_evaluacion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      periodo_id INTEGER NOT NULL,
      nombre_apartado TEXT NOT NULL,
      porcentaje REAL NOT NULL CHECK(porcentaje BETWEEN 0 AND 100),
      es_defecto INTEGER CHECK(es_defecto IN (0, 1)),
      FOREIGN KEY (periodo_id) REFERENCES periodos(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE asistencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha TEXT NOT NULL,
      estudiante_id INTEGER NOT NULL,
      estado TEXT NOT NULL CHECK(estado IN ('Presente', 'Ausente', 'Justificado')),
      foto_justificacion TEXT,
      FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE visitas_padres (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      estudiante_id INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      nombre_representante TEXT NOT NULL,
      motivo TEXT,
      firma TEXT,
      FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE temas_personalizados (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      materia_curso_id INTEGER NOT NULL,
      curso_id INTEGER NOT NULL,
      titulo TEXT NOT NULL,
      FOREIGN KEY (materia_curso_id) REFERENCES materias_curso(id) ON DELETE CASCADE,
      FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE alertas_enviadas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      estudiante_id INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      motivo TEXT NOT NULL,
      FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE horario_clase (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dia TEXT NOT NULL,
      hora INTEGER NOT NULL,
      materia_curso_id INTEGER NOT NULL,
      FOREIGN KEY (materia_curso_id) REFERENCES materias_curso(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('CREATE INDEX idx_materias_nombre ON materias(nombre);');
  await db.execute(
    'CREATE INDEX idx_estudiantes_curso ON estudiantes(curso_id);',
  );
  await db.execute(
    'CREATE INDEX idx_evaluaciones_materia ON evaluaciones(materia_curso_id);',
  );
  await db.execute(
    'CREATE INDEX idx_notas_estudiante ON notas(estudiante_id);',
  );
  await db.execute(
    'CREATE INDEX idx_asistencias_fecha ON asistencias(fecha, estudiante_id);',
  );
  await db.execute(
    'CREATE INDEX idx_visitas_padres_fecha ON visitas_padres(fecha, estudiante_id);',
  );

  await _insertarTiposMateria(db);
  await _insertarMateriasPorDefecto(db);
}

Future<void> _insertarTiposMateria(Database db) async {
  final tipos = [
    {'nombre': 'Educación Inicial y Preparatoria', 'sigla': 'I'},
    {'nombre': 'EGB y Bachillerato General', 'sigla': 'EGB-BGU'},
    {'nombre': 'Bachillerato Técnico', 'sigla': 'BT'},
    {'nombre': 'Bachillerato Internacional', 'sigla': 'BI'},
  ];

  for (final tipo in tipos) {
    await db.insert(
      'tipos_materia',
      tipo,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}

Future<void> _insertarMateriasPorDefecto(Database db) async {
  final count = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM materias'),
  );

  if (count == 0) {
    final materiasPorTipo = {
      'I': [
        'MOTRICIDAD',
        'LENGUAJE Y COMUNICACIÓN',
        'RELACIONES LÓGICO-MATEMÁTICAS',
        'EXPRESIÓN ARTÍSTICA',
        'MEDIO NATURAL Y CULTURAL',
        'DESTREZAS DE LA VIDA COTIDIANA',
        'JUEGO Y APRENDIZAJE',
        'EDUCACIÓN MUSICAL',
      ],
      'EGB-BGU': [
        'MATEMÁTICA',
        'LENGUA Y LITERATURA',
        'CIENCIAS NATURALES',
        'ESTUDIOS SOCIALES',
        'EDUCACIÓN FÍSICA',
        'INGLÉS',
        'EDUCACIÓN CULTURAL Y ARTÍSTICA',
        'FÍSICA',
        'QUÍMICA',
        'BIOLOGÍA',
        'HISTORIA',
        'FILOSOFÍA',
        'ECONOMÍA',
        'EDUCACIÓN PARA LA CIUDADANÍA',
        'EMPRENDIMIENTO Y GESTIÓN',
        'TIC (TECNOLOGÍAS DE LA INFORMACIÓN Y LA COMUNICACIÓN)',
        'ACOMPAÑAMIENTO INTEGRAL EN EL AULA',
        'ANIMACIÓN A LA LECTURA',
        'ORIENTACIÓN VOCACIONAL PROFESIONAL',
      ],
      'BT': [
        'CONTABILIDAD',
        'ELECTRÓNICA',
        'MECÁNICA AUTOMOTRIZ',
        'ADMINISTRACIÓN',
        'SERVICIOS HOTELEROS',
        'DESARROLLO DE SOFTWARE',
        'AGROPECUARIA',
        'DISEÑO GRÁFICO',
        'ENFERMERÍA',
      ],
      'BI': [
        'TEORÍA DEL CONOCIMIENTO (TOK)',
        'MONOGRAFÍA',
        'CREATIVIDAD, ACTIVIDAD Y SERVICIO (CAS)',
      ],
    };

    for (final sigla in materiasPorTipo.keys) {
      final tipoId = Sqflite.firstIntValue(
        await db.rawQuery('SELECT id FROM tipos_materia WHERE sigla = ?', [
          sigla,
        ]),
      );

      if (tipoId != null) {
        for (final nombre in materiasPorTipo[sigla]!) {
          await db.insert('materias', {
            'nombre': nombre,
            'tipo_id': tipoId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }
  }
}
