/// Compara si dos fechas son del mismo día (ignora hora)
bool esMismoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Verifica si una fecha es hoy
bool esFechaHoy(DateTime fecha) {
  return esMismoDia(fecha, DateTime.now());
}

/// Verifica si una fecha es futura (excluye hoy)
bool esFechaFutura(DateTime fecha) {
  final hoy = DateTime.now();
  final fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
  final hoyNormalizada = DateTime(hoy.year, hoy.month, hoy.day);
  return fechaNormalizada.isAfter(hoyNormalizada);
}

/// Verifica si una fecha es pasada (excluye hoy)
bool esFechaPasada(DateTime fecha) {
  final hoy = DateTime.now();
  final fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
  final hoyNormalizada = DateTime(hoy.year, hoy.month, hoy.day);
  return fechaNormalizada.isBefore(hoyNormalizada);
}

/// Obtiene el lunes de la semana de una fecha dada
DateTime obtenerLunesDeSemana(DateTime referencia) {
  return referencia.subtract(
    Duration(days: referencia.weekday - DateTime.monday),
  );
}

/// Obtiene la fecha correspondiente a un día de la semana desde un lunes base
DateTime obtenerFechaDelDia(String dia, DateTime lunesBase) {
  final diasMap = {
    'Lunes': 0,
    'Martes': 1,
    'Miércoles': 2,
    'Jueves': 3,
    'Viernes': 4,
  };
  return lunesBase.add(Duration(days: diasMap[dia]!));
}

/// Verifica si una semana completa está en el futuro
bool esSemanaFuturaCompleta(List<DateTime> semana) {
  final hoy = DateTime.now();
  return semana.every((d) => d.isAfter(hoy));
}

/// Obtiene el índice del día actual en una semana
int obtenerDiaVisibleIndex(DateTime hoy, List<String> dias) {
  final weekday = hoy.weekday;
  final index = weekday >= 6 ? 4 : weekday - 1;
  return index.clamp(0, dias.length - 1);
}
