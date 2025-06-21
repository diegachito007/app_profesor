import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  static Database? _database;

  static Future<bool> databaseExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'profeshor.db');
    return File(path).exists();
  }

  static Future<void> eliminarBaseDeDatos() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'profeshor.db');
    if (await File(path).exists()) {
      await deleteDatabase(path);
      debugPrint('🧨 Base de datos eliminada con éxito');
    }
  }

  static Future<void> inicializarBaseDeDatos() async {
    if (_database != null && _database!.isOpen) {
      debugPrint('📦 Reutilizando instancia de base de datos existente');
      return;
    }
    _database = await getDatabase();
  }

  static Future<Database> getDatabase() async {
    if (_database != null && _database!.isOpen) {
      debugPrint('📦 Base de datos ya inicializada');
      return _database!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'profeshor.db');
    debugPrint('📂 Ruta BD: $path');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        try {
          await _crearTablas(db);
          await _insertarDatosEjemplo(db);
          debugPrint('✅ Tablas y datos de ejemplo creados');
        } catch (e, stack) {
          debugPrint('❌ Error al crear estructura inicial: $e');
          debugPrintStack(stackTrace: stack);
          rethrow;
        }
      },
    );

    return _database!;
  }

  static Future<void> _crearTablas(Database db) async {
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
        periodo_id INTEGER NOT NULL,
        FOREIGN KEY (periodo_id) REFERENCES periodos(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE materias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        curso_id INTEGER NOT NULL,
        FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
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
        materia_id INTEGER NOT NULL,
        ponderacion REAL NOT NULL CHECK(ponderacion BETWEEN 0 AND 100),
        trimestre TEXT NOT NULL CHECK(trimestre IN ('1', '2', '3')),
        FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE CASCADE
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
        materia_id INTEGER NOT NULL,
        curso_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        FOREIGN KEY (materia_id) REFERENCES materias(id) ON DELETE CASCADE,
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

    await db.execute(
      'CREATE INDEX idx_estudiantes_curso ON estudiantes(curso_id);',
    );
    await db.execute(
      'CREATE INDEX idx_evaluaciones_materia ON evaluaciones(materia_id);',
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
  }

  static Future<void> _insertarDatosEjemplo(Database db) async {
    await db.insert('periodos', {
      'nombre': 'Periodo 2024 - A',
      'fecha_inicio': '2024-01-15T00:00:00.000',
      'fecha_fin': '2024-06-30T00:00:00.000',
      'activo': 0,
    });
    await db.insert('periodos', {
      'nombre': 'Periodo 2024 - B',
      'fecha_inicio': '2024-07-01T00:00:00.000',
      'fecha_fin': '2024-12-15T00:00:00.000',
      'activo': 0,
    });
    await db.insert('periodos', {
      'nombre': 'Periodo 2025 - A',
      'fecha_inicio': '2025-01-10T00:00:00.000',
      'fecha_fin': '2025-06-25T00:00:00.000',
      'activo': 1, // este será el activo por defecto
    });
  }
}
