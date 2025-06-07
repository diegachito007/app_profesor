import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  static Database? _database;

  /// ✅ Verifica si la base de datos ya existe
  static Future<bool> databaseExists() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/profeshor.db';
    return File(dbPath).exists();
  }

  /// ✅ Obtiene la instancia de la base de datos
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/profeshor.db';

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await _crearTablas(db);
      },
    );

    return _database!;
  }

  /// ✅ Inicializa la base de datos creando las tablas
  static Future<void> inicializarBaseDeDatos() async {
    final db = await getDatabase();
    await _crearTablas(db);
  }

  /// ✅ Define la estructura de todas las tablas
  static Future<void> _crearTablas(Database db) async {
    await db.execute('''
      CREATE TABLE periodos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        fecha_inicio TEXT NOT NULL,
        fecha_fin TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cursos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        periodo_id INTEGER NOT NULL,
        FOREIGN KEY (periodo_id) REFERENCES periodos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE materias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        curso_id INTEGER NOT NULL,
        FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
      )
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
      )
    ''');

    await db.execute('''
      CREATE TABLE evaluaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        descripcion TEXT,
        fecha TEXT NOT NULL,
        materia_id INTEGER NOT NULL,
        ponderacion REAL NOT NULL CHECK(ponderacion >= 0 AND ponderacion <= 100),
        trimestre TEXT NOT NULL CHECK(trimestre IN ('1', '2', '3')),
        FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estudiante_id INTEGER NOT NULL,
        evaluacion_id INTEGER NOT NULL,
        nota REAL NOT NULL CHECK(nota >= 0 AND nota <= 10),
        estado TEXT CHECK(estado IN ('Regular', 'Recuperado', 'No asistió')),
        fecha_recuperacion TEXT,
        FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
        FOREIGN KEY (evaluacion_id) REFERENCES evaluaciones(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE esquemas_evaluacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        periodo_id INTEGER NOT NULL,
        nombre_apartado TEXT NOT NULL,
        porcentaje REAL NOT NULL CHECK(porcentaje >= 0 AND porcentaje <= 100),
        es_defecto INTEGER CHECK(es_defecto IN (0, 1)),
        FOREIGN KEY (periodo_id) REFERENCES periodos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE asistencias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        estudiante_id INTEGER NOT NULL,
        estado TEXT NOT NULL CHECK(estado IN ('Presente', 'Ausente', 'Justificado')),
        foto_justificacion TEXT,
        FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
      )
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
      )
    ''');

    await db.execute('''
      CREATE TABLE temas_personalizados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materia_id INTEGER NOT NULL,
        curso_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE CASCADE,
        FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE alertas_enviadas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estudiante_id INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        motivo TEXT NOT NULL,
        FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
      )
    ''');

    // ✅ Índices para mejorar rendimiento en consultas
    await db.execute(
      "CREATE INDEX idx_estudiantes_curso ON estudiantes(curso_id)",
    );
    await db.execute(
      "CREATE INDEX idx_evaluaciones_materia ON evaluaciones(materia_id)",
    );
    await db.execute(
      "CREATE INDEX idx_notas_estudiante ON notas(estudiante_id)",
    );
    await db.execute(
      "CREATE INDEX idx_asistencias_fecha ON asistencias(fecha, estudiante_id)",
    );
    await db.execute(
      "CREATE INDEX idx_visitas_padres_fecha ON visitas_padres(fecha, estudiante_id)",
    );
  }
}
