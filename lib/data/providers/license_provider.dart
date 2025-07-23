import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/license/license_storage.dart';

final nombrePropietarioProvider = FutureProvider<String?>((ref) async {
  return await LicenseStorage.getNombreUsuario();
});
