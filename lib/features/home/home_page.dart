import 'package:flutter/material.dart';
import 'home_controller.dart';
import '../../data/database/license_storage.dart';
import '../dashboard/dashboard_page.dart'; // Importa la pantalla de Dashboard

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = HomeController();
  bool licenciaValidada = false;
  bool cargando = true; // ✅ Se inicia en "true" para evitar pantalla negra

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

      _mostrarBienvenida(
        () => _irADashboard(),
      ); // ✅ Muestra diálogo antes de ir al Dashboard
      return;
    }

    final licenciaActiva = await controller.validarLicencia();
    if (!mounted) return;

    if (licenciaActiva) {
      setState(() {
        licenciaValidada = true;
        cargando = false;
      });

      _mostrarBienvenida(
        () => _irADashboard(),
      ); // ✅ Muestra diálogo antes de ir al Dashboard
    } else {
      setState(() => cargando = false); // ✅ Si falla, muestra el contenido
    }
  }

  void _mostrarBienvenida(VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text("Bienvenido a Profeshor 1.0"),
        content: SizedBox(
          width: 200,
          height: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(), // ✅ Barra de progreso animada
              SizedBox(height: 10),
              Text("Cargando..."),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // ✅ Cierra el diálogo de bienvenida
      onComplete(); // ✅ Continúa con la navegación al Dashboard
    });
  }

  void _irADashboard() {
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
            ? const CircularProgressIndicator() // ✅ Muestra carga mientras verifica
            : licenciaValidada
            ? const SizedBox() // ✅ Evita pantalla negra si la licencia es válida
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
