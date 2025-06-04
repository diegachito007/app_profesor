import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/license_storage.dart';

class HomeController {
  final SupabaseClient supabase = Supabase.instance.client;
  final Logger logger = Logger();

  Future<Map<String, dynamic>?> verificarLicencia(String licenciaCodigo) async {
    final response = await supabase
        .from('licencias')
        .select('nombre')
        .eq('codigo', licenciaCodigo)
        .limit(1)
        .maybeSingle();

    return response;
  }

  Future<bool> validarLicencia() async {
    final licenciaGuardada = await LicenseStorage.isLicenseValid();
    if (licenciaGuardada) return true;

    final prefs = await SharedPreferences.getInstance();
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

  Future<String?> obtenerUsuario() async {
    return await LicenseStorage.getNombreUsuario();
  }
}
