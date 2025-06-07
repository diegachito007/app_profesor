import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/license_storage.dart';

class HomeController {
  final SupabaseClient supabase = Supabase.instance.client;
  final Logger logger = Logger();
  late SharedPreferences prefs;

  /// Inicializa `SharedPreferences` una sola vez
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Verifica si la licencia existe en Supabase con manejo de errores
  Future<Map<String, dynamic>?> verificarLicencia(String licenciaCodigo) async {
    try {
      final response = await supabase
          .from('licencias')
          .select('nombre')
          .eq('codigo', licenciaCodigo)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e, stacktrace) {
      logger.e(
        "❌ Error al verificar licencia en Supabase",
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  /// Valida la licencia almacenada o consulta a Supabase
  Future<bool> validarLicencia() async {
    await init(); // 🔹 Inicializa `SharedPreferences` antes de usarlo

    final licenciaGuardada = await LicenseStorage.isLicenseValid();
    if (licenciaGuardada) return true;

    final licenciaCodigo = prefs.getString('licencia_codigo');

    if (licenciaCodigo != null) {
      final response = await verificarLicencia(licenciaCodigo);
      if (response != null) {
        await LicenseStorage.saveLicense(response['nombre']);
        await prefs.setBool('licencia_activa', true);
        return true;
      }
    }
    return false;
  }

  /// Obtiene el usuario almacenado en LicenseStorage
  Future<String?> obtenerUsuario() async {
    return await LicenseStorage.getNombreUsuario();
  }
}
