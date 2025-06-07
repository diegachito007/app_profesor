import 'package:flutter/material.dart';
import '../../data/controllers/home_controller.dart';
import '../../data/database/license_storage.dart';
import '../../data/database/sqlite_service.dart'; // ✅ Importación de SQLite
import '../dashboard/dashboard_page.dart'; // Importa la pantalla de Dashboard

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = HomeController();
  bool licenciaValidada = false;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarLicencia();
  }

  Future<void> _cargarLicencia() async {
    final licenciaGuardada = await LicenseStorage.isLicenseValid();
    if (!mounted) return;

    if (licenciaGuardada) {
      setState(() {
        licenciaValidada = true;
        cargando = false;
      });

      _mostrarBienvenida(); // ✅ Muestra el diálogo antes de ir al Dashboard
      return;
    }

    final licenciaActiva = await controller.validarLicencia();
    if (!mounted) return;

    if (licenciaActiva) {
      setState(() {
        licenciaValidada = true;
        cargando = false;
      });

      _mostrarBienvenida(); // ✅ Muestra el diálogo antes de ir al Dashboard
    } else {
      setState(() => cargando = false);
    }
  }

  void _mostrarBienvenida() async {
    if (!mounted) {
      return; // ✅ Verifica que el widget aún existe antes de mostrar el diálogo
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text("Bienvenido"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Preparando la aplicación..."),
            SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(), // ✅ Barra de progreso animada
            ),
          ],
        ),
      ),
    );

    await _verificarBaseDeDatos(); // ✅ Verifica y crea la BD si es necesario

    if (!mounted) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // ✅ Verifica antes de cerrar el diálogo
      Navigator.pop(context); // ✅ Cierra el diálogo sin errores
      _irADashboard(); // ✅ Va al Dashboard
    });
  }

  Future<void> _verificarBaseDeDatos() async {
    final dbExiste = await SQLiteService.databaseExists();
    if (!dbExiste) {
      await SQLiteService.inicializarBaseDeDatos(); // ✅ Crea la BD si no existe
    }
  }

  void _irADashboard() {
    if (!mounted) return; // ✅ Verifica antes de navegar
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: cargando
            ? const CircularProgressIndicator()
            : licenciaValidada
            ? const SizedBox()
            : ElevatedButton(
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
