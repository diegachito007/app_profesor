import 'package:shared_preferences/shared_preferences.dart';

class LicenseStorage {
  static Future<void> saveLicense(String nombreUsuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('licencia_activa', true);
    await prefs.setString('nombre_usuario', nombreUsuario);
  }

  static Future<bool> isLicenseValid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('licencia_activa') ?? false;
  }

  static Future<String?> getNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre_usuario');
  }
}
