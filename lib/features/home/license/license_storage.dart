import 'package:shared_preferences/shared_preferences.dart';

class LicenseStorage {
  static const _keyActiva = 'licencia_activa';
  static const _keyNombre = 'licencia_nombre';
  static const _keyCodigo = 'licencia_codigo';

  static Future<void> guardarLicencia(String codigo, String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActiva, true);
    await prefs.setString(_keyNombre, nombre);
    await prefs.setString(_keyCodigo, codigo);
  }

  static Future<bool> esLicenciaValida() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyActiva) ?? false;
  }

  static Future<String?> getNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNombre);
  }

  static Future<String?> getCodigoLicencia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCodigo);
  }

  static Future<void> borrarLicencia() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiva);
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyCodigo);
  }
}
