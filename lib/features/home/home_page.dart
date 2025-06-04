import 'package:flutter/material.dart';
import 'home_controller.dart';
import '../../data/database/license_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = HomeController();
  String tituloApp = "Profeshor1.0";

  @override
  void initState() {
    super.initState();
    _cargarLicencia();
  }

  Future<void> _cargarLicencia() async {
    final licenciaGuardada = await LicenseStorage.isLicenseValid();
    if (licenciaGuardada) {
      final nombreUsuario = await LicenseStorage.getNombreUsuario();
      setState(() {
        tituloApp = "Profeshor1.0 - $nombreUsuario";
      });

      _mostrarDialogoCarga();

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }

    final licenciaActiva = await controller.validarLicencia();
    if (licenciaActiva) {
      final nombreUsuario = await controller.obtenerUsuario();
      setState(() {
        tituloApp = "Profeshor1.0 - $nombreUsuario";
      });

      _mostrarDialogoCarga();

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _mostrarDialogoCarga() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Cargando, por favor espera..."),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tituloApp)),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (!mounted) return;
            Navigator.pushNamed(context, '/licencia');
          },
          child: const Text("Activar Licencia"),
        ),
      ),
    );
  }
}
