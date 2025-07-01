PRAGMA foreign_keys = ON;

-- Tabla: periodos
CREATE TABLE periodos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  fecha_inicio TEXT NOT NULL,
  fecha_fin TEXT NOT NULL,
  activo INTEGER DEFAULT 0
);

-- Tabla: cursos
CREATE TABLE cursos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  paralelo TEXT NOT NULL,
  periodo_id INTEGER NOT NULL,
  activo INTEGER DEFAULT 1,
  FOREIGN KEY (periodo_id) REFERENCES periodos(id) ON DELETE CASCADE
);

-- Tabla: materias (catálogo general)
CREATE TABLE materias (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL UNIQUE
);

-- Tabla: curso-materia
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

-- Tabla: estudiantes
CREATE TABLE estudiantes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cedula TEXT NOT NULL UNIQUE CHECK(length(cedula) <= 10),
  nombre TEXT NOT NULL,
  apellido TEXT NOT NULL,
  curso_id INTEGER NOT NULL,
  telefono TEXT CHECK(length(telefono) >= 10),
  FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
);

-- Tabla: evaluaciones (ahora referencian materias_curso)
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

-- Tabla: notas
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

-- Tabla: esquemas_evaluacion
CREATE TABLE esquemas_evaluacion (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  periodo_id INTEGER NOT NULL,
  nombre_apartado TEXT NOT NULL,
  porcentaje REAL NOT NULL CHECK(porcentaje BETWEEN 0 AND 100),
  es_defecto INTEGER CHECK(es_defecto IN (0, 1)),
  FOREIGN KEY (periodo_id) REFERENCES periodos(id) ON DELETE CASCADE
);

-- Tabla: asistencias
CREATE TABLE asistencias (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fecha TEXT NOT NULL,
  estudiante_id INTEGER NOT NULL,
  estado TEXT NOT NULL CHECK(estado IN ('Presente', 'Ausente', 'Justificado')),
  foto_justificacion TEXT,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
);

-- Tabla: visitas_padres
CREATE TABLE visitas_padres (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  estudiante_id INTEGER NOT NULL,
  fecha TEXT NOT NULL,
  nombre_representante TEXT NOT NULL,
  motivo TEXT,
  firma TEXT,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
);

-- Tabla: temas_personalizados (actualizada para usar materias_curso)
CREATE TABLE temas_personalizados (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  materia_curso_id INTEGER NOT NULL,
  curso_id INTEGER NOT NULL,
  titulo TEXT NOT NULL,
  FOREIGN KEY (materia_curso_id) REFERENCES materias_curso(id) ON DELETE CASCADE,
  FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
);

-- Tabla: alertas_enviadas
CREATE TABLE alertas_enviadas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  estudiante_id INTEGER NOT NULL,
  fecha TEXT NOT NULL,
  motivo TEXT NOT NULL,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
);

-- Índices
CREATE INDEX idx_estudiantes_curso ON estudiantes(curso_id);
CREATE INDEX idx_evaluaciones_materia ON evaluaciones(materia_curso_id);
CREATE INDEX idx_notas_estudiante ON notas(estudiante_id);
CREATE INDEX idx_asistencias_fecha ON asistencias(fecha, estudiante_id);
CREATE INDEX idx_visitas_padres_fecha ON visitas_padres(fecha, estudiante_id);