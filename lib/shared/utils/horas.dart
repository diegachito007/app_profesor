/// Lista estándar de bloques horarios (puedes ajustar según tu institución)
const List<int> bloquesHorarios = [1, 2, 3, 4, 5, 6, 7];

/// Normaliza una fecha quitando la hora (útil para comparaciones)
DateTime normalizarFecha(DateTime fecha) {
  return DateTime(fecha.year, fecha.month, fecha.day);
}

/// Verifica si una hora está dentro del rango permitido
bool esHoraValida(int hora) {
  return bloquesHorarios.contains(hora);
}

/// Formatea una hora como texto (puedes personalizar según tu sistema)
String formatearBloque(int hora) {
  return 'Bloque $hora';
}
